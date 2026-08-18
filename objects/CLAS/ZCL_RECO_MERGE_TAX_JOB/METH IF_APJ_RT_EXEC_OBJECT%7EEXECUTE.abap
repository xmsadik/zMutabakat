  METHOD if_apj_rt_exec_object~execute.

    TYPES : BEGIN OF ty_erdat_range,
              sign   TYPE c LENGTH 1,
              option TYPE c LENGTH 2,
              low    TYPE erdat,
              high   TYPE erdat,
            END OF ty_erdat_range,
            BEGIN OF ty_kunnr_range,
              sign   TYPE c LENGTH 1,
              option TYPE c LENGTH 2,
              low    TYPE kunnr,
              high   TYPE kunnr,
            END OF ty_kunnr_range,
            BEGIN OF ty_lifnr_range,
              sign   TYPE c LENGTH 1,
              option TYPE c LENGTH 2,
              low    TYPE lifnr,
              high   TYPE lifnr,
            END OF ty_lifnr_range,
            tt_erdat_range TYPE TABLE OF ty_erdat_range WITH EMPTY KEY,
            tt_kunnr_range TYPE TABLE OF ty_kunnr_range WITH EMPTY KEY,
            tt_lifnr_range TYPE TABLE OF ty_lifnr_range WITH EMPTY KEY.

    TYPES: BEGIN OF ty_bukrs,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE bukrs,
             high   TYPE bukrs,
           END OF ty_bukrs.

    DATA lr_erdat TYPE tt_erdat_range.
    DATA lr_kunnr TYPE tt_kunnr_range.
    DATA lr_lifnr TYPE tt_lifnr_range.
    DATA r_bukrs  TYPE TABLE OF ty_bukrs.

    DATA: lt_taxm    TYPE TABLE OF zreco_taxm,
          ls_taxm    TYPE zreco_taxm,
          lt_taxn    TYPE TABLE OF zreco_taxn,
          ls_taxn    TYPE zreco_taxn,
          lv_count_m TYPE i,
          lv_count_n TYPE i.

    FIELD-SYMBOLS: <lr_bukrs> TYPE ty_bukrs.

*    LOOP AT it_parameters INTO DATA(ls_parameter).
*      CASE ls_parameter-selname.
*        WHEN 'S_ERDAT'.
*          APPEND VALUE #( sign = ls_parameter-sign
*                          option = ls_parameter-option
*                          low = ls_parameter-low
*                          high = ls_parameter-high ) TO lr_erdat.
*        WHEN 'S_KUNNR'.
*          APPEND VALUE #( sign = ls_parameter-sign
*                          option = ls_parameter-option
*                          low = ls_parameter-low
*                          high = ls_parameter-high ) TO lr_kunnr.
*        WHEN 'S_LIFNR'.
*          APPEND VALUE #( sign = ls_parameter-sign
*                          option = ls_parameter-option
*                          low = ls_parameter-low
*                          high = ls_parameter-high ) TO lr_lifnr.
*        WHEN 'P_SELD'.
*          DATA(lv_seld) = CONV bukrs( ls_parameter-low ).
*        WHEN 'P_SELK'.
*          DATA(lv_selk) = CONV bukrs( ls_parameter-low ).
*        WHEN 'P_BLK'.
*          DATA(lv_blk) = CONV bukrs( ls_parameter-low ).
*        WHEN 'P_DEL'.
*          DATA(lv_del) = CONV bukrs( ls_parameter-low ).
*      ENDCASE.
*    ENDLOOP.

*    TRY.
*        DATA(lo_log) = cl_bali_log=>create_with_header( cl_bali_header_setter=>create( object = 'ZETR_RECO_LOG'
*                                                                                       subobject = 'ZETR_RECO_MERGE_TAX' ) ).
*      CATCH cx_bali_runtime.
*    ENDTRY.


*    DATA(lo_message) = cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_information
*                                                       id = 'ZRECO'
*                                                       number = 226 ).

*    TRY.
*        lo_log->add_item( lo_message ).
*      CATCH cx_bali_runtime.
*    ENDTRY.

    SELECT * FROM zreco_adrs INTO TABLE @DATA(lt_adrs).

    LOOP AT lt_adrs INTO DATA(ls_adrs).
      APPEND INITIAL LINE TO r_bukrs ASSIGNING <lr_bukrs>.
      <lr_bukrs>-sign = 'I'.
      <lr_bukrs>-option = 'EQ'.
      <lr_bukrs>-low = ls_adrs-bukrs.
    ENDLOOP.

    CLEAR : lt_taxm,lt_taxn,
            lv_count_m, lv_count_n.

    SELECT kna1~customer AS kunnr,
           kna1~AddressID AS adrnr,
           kna1~FiscalAddress AS fiskn,
           kna1~CustomerAccountGroup AS ktokd,
           kna1~supplier AS lifnr,
           kna1~TaxNumber1 AS stcd1,
           kna1~TaxNumber2 AS stcd2,
           kna1~VATRegistration AS stceg,
           kna1~TaxNumber3 AS stcd3,
           kna1~TaxNumber4 AS stcd4
      FROM i_customer AS  kna1 INNER JOIN i_customercompany AS knb1 ON knb1~customer EQ kna1~customer
      WHERE knb1~CompanyCode IN @r_bukrs
      AND knb1~ReconciliationAccount NE ''
      AND kna1~IsOneTimeAccount EQ ''
      INTO TABLE @DATA(lt_kna1).

    IF sy-subrc EQ 0.

      LOOP AT lt_kna1 INTO DATA(s_kna1).

        CLEAR: ls_taxm, ls_taxn.

        ls_taxm-hesap_tur = 'M'.
        ls_taxm-hesap_no = s_kna1-kunnr.
        ls_taxm-ktokl = s_kna1-ktokd.
        ls_taxm-kunnr = s_kna1-kunnr.
        ls_taxm-lifnr = s_kna1-lifnr.
        ls_taxm-adrnr = s_kna1-adrnr.

        CASE ls_adrs-tax_number.
          WHEN 'STCD1'.
            ls_taxm-vkn_tckn = s_kna1-stcd1.
          WHEN 'STCD2'.
            ls_taxm-vkn_tckn = s_kna1-stcd2.
          WHEN 'STCD3'.
            ls_taxm-vkn_tckn = s_kna1-stcd3.
          WHEN 'STCD4'.
            ls_taxm-vkn_tckn = s_kna1-stcd4.
          WHEN 'STCEG'.
            ls_taxm-vkn_tckn = s_kna1-stceg.
          WHEN 'FISKN'.
            ls_taxm-vkn_tckn = s_kna1-fiskn.
        ENDCASE.

        IF ls_adrs-tax_person IS NOT INITIAL AND
           ls_taxm-vkn_tckn IS INITIAL.

          CASE ls_adrs-tax_person.
            WHEN 'STCD1'.
              ls_taxm-vkn_tckn = s_kna1-stcd1.
            WHEN 'STCD2'.
              ls_taxm-vkn_tckn = s_kna1-stcd2.
            WHEN 'STCD3'.
              ls_taxm-vkn_tckn = s_kna1-stcd3.
            WHEN 'STCD4'.
              ls_taxm-vkn_tckn = s_kna1-stcd4.
            WHEN 'STCEG'.
              ls_taxm-vkn_tckn = s_kna1-stceg.
            WHEN 'FISKN'.
              ls_taxm-vkn_tckn = s_kna1-fiskn.
          ENDCASE.

        ENDIF.

        IF ls_taxm IS NOT INITIAL.
          APPEND ls_taxm TO lt_taxm.
          lv_count_m = lv_count_m + 1.
        ENDIF.

      ENDLOOP.

    ENDIF.

    SELECT lfa1~supplier AS lifnr,
           lfa1~AddressID AS adrnr,
           lfa1~FiscalAddress AS fiskn,
           lfa1~SupplierAccountGroup AS ktokk,
           lfa1~Customer AS kunnr,
           lfa1~TaxNumber1 AS stcd1,
           lfa1~TaxNumber2 AS stcd2,
           lfa1~VATRegistration AS stceg,
           lfa1~TaxNumber3 AS stcd3,
           lfa1~TaxNumber4 AS stcd4
      FROM i_supplier AS lfa1 INNER JOIN i_suppliercompany AS lfb1 ON lfb1~supplier EQ lfa1~supplier
      WHERE lfb1~companycode IN @r_bukrs
        AND lfb1~ReconciliationAccount NE ''
        AND lfa1~IsOneTimeAccount EQ ''
   INTO TABLE @DATA(lt_lfa1).

    IF sy-subrc EQ 0.
      LOOP AT lt_lfa1 INTO DATA(s_lfa1).

        CLEAR: ls_taxm, ls_taxn.

        ls_taxm-hesap_tur = 'S'.
        ls_taxm-hesap_no = s_lfa1-lifnr.
        ls_taxm-ktokl = s_lfa1-ktokk.
        ls_taxm-kunnr = s_lfa1-kunnr.
        ls_taxm-lifnr = s_lfa1-lifnr.
        ls_taxm-adrnr = s_lfa1-adrnr.

        CASE ls_adrs-tax_number.
          WHEN 'STCD1'.
            ls_taxm-vkn_tckn = s_lfa1-stcd1.
          WHEN 'STCD2'.
            ls_taxm-vkn_tckn = s_lfa1-stcd2.
          WHEN 'STCD3'.
            ls_taxm-vkn_tckn = s_lfa1-stcd3.
          WHEN 'STCD4'.
            ls_taxm-vkn_tckn = s_lfa1-stcd4.
          WHEN 'STCEG'.
            ls_taxm-vkn_tckn = s_lfa1-stceg.
          WHEN 'FISKN'.
            ls_taxm-vkn_tckn = s_lfa1-fiskn.
        ENDCASE.

        IF ls_adrs-tax_person IS NOT INITIAL AND
           ls_taxm-vkn_tckn IS INITIAL.

          CASE ls_adrs-tax_person.
            WHEN 'STCD1'.
              ls_taxm-vkn_tckn = s_lfa1-stcd1.
            WHEN 'STCD2'.
              ls_taxm-vkn_tckn = s_lfa1-stcd2.
            WHEN 'STCD3'.
              ls_taxm-vkn_tckn = s_lfa1-stcd3.
            WHEN 'STCD4'.
              ls_taxm-vkn_tckn = s_lfa1-stcd4.
            WHEN 'STCEG'.
              ls_taxm-vkn_tckn = s_lfa1-stceg.
            WHEN 'FISKN'.
              ls_taxm-vkn_tckn = s_lfa1-fiskn.
          ENDCASE.

        ENDIF.

        IF ls_taxm IS NOT INITIAL.
          APPEND ls_taxm TO lt_taxm.
          lv_count_m = lv_count_m + 1.
        ENDIF.

      ENDLOOP.

      IF lt_taxm[] IS NOT INITIAL.
        MODIFY zreco_taxm FROM TABLE @lt_taxm.
        CLEAR : lt_taxm, lv_count_m.
        COMMIT WORK AND WAIT .
      ENDIF.

*      lo_message = cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_information
*                                                         id = 'ZRECO'
*                                                         number = 227 ).

*      TRY.
*          lo_log->add_item( lo_message ).
*        CATCH cx_bali_runtime.
*      ENDTRY.

    ENDIF.

*    IF lo_log IS NOT INITIAL.
*      TRY.
*          cl_bali_log_db=>get_instance( )->save_log( log = lo_log assign_to_current_appl_job = abap_true ).
*        CATCH cx_bali_runtime.
*      ENDTRY.
*    ENDIF.

  ENDMETHOD.