  METHOD if_rap_query_provider~select.
    DATA lv_field     TYPE string.
    TRY.

        DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).

        DATA(lo_paging) = io_request->get_paging( ).
        DATA(lv_top) = lo_paging->get_page_size( ).
        IF lv_top < 0.
          lv_top = 1.
        ENDIF.

        DATA(lv_skip) = lo_paging->get_offset( ).



        DATA: lt_period_range  TYPE RANGE OF monat,
              lt_gjahr_range   TYPE RANGE OF gjahr,
              lt_daily_range   TYPE RANGE OF abap_boolean,
              lt_p_rdate_range TYPE RANGE OF budat,
              lt_p_gsber_range TYPE RANGE OF abap_boolean,
              lt_p_waers_range TYPE RANGE OF abap_boolean,
              lt_p_seld_range  TYPE RANGE OF abap_boolean,
              lt_p_selk_range  TYPE RANGE OF abap_boolean,
              lt_p_tran_range  TYPE RANGE OF abap_boolean,
              lt_p_all_range   TYPE RANGE OF abap_boolean,
              lt_p_blist_range TYPE RANGE OF abap_boolean,
              lt_p_diff_range  TYPE RANGE OF abap_boolean,

              lt_p_last_range  TYPE RANGE OF abap_boolean,
              lt_p_cred_range  TYPE RANGE OF abap_boolean,
              lt_p_print_range TYPE RANGE OF p_print,
              lt_limit_range   TYPE RANGE OF wrbtr,
              lt_p_shk_range   TYPE RANGE OF abap_boolean,
              lt_p_date_range  TYPE RANGE OF datum,
              lt_p_bli_range   TYPE RANGE OF abap_boolean,
              lt_p_bsiz_range  TYPE RANGE OF abap_boolean,
              lt_p_exch_range  TYPE RANGE OF abap_boolean,
              lt_p_zero_range  TYPE RANGE OF abap_boolean,
              lt_p_sgli_range  TYPE RANGE OF abap_boolean,
              lt_p_novl_range  TYPE RANGE OF abap_boolean,
              lt_p_nolc_range  TYPE RANGE OF abap_boolean,
              lt_p_ek_alan     TYPE RANGE OF abap_boolean,
              lt_s_smkod_range TYPE RANGE OF zreco_salma,
              lt_s_salma_range TYPE RANGE OF zreco_smkod,

              lt_output        TYPE TABLE OF zreco_ddl_i_reco_form,
              ls_output        TYPE zreco_ddl_i_reco_form,
              lt_output_detail TYPE TABLE OF zreco_ddl_i_reco_form.


        DATA(lt_paging) = io_request->get_paging( ).
*
        LOOP AT lt_filter INTO DATA(ls_filter).
          CASE ls_filter-name.
            WHEN 'PERIOD'.
              lt_period_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'GJAHR'.
              lt_gjahr_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_DAILY'.
              lt_daily_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'BUDAT'.
              lt_p_rdate_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'BUKRS'.
              s_bukrs = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_GSBER'.
              lt_p_gsber_range =  CORRESPONDING #( ls_filter-range ).
            WHEN 'GSBER'.
              s_gsber = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_WAERS'.
              lt_p_waers_range =  CORRESPONDING #( ls_filter-range ).
            WHEN 'WAERS'.
              s_waers = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_SELD'.
              lt_p_seld_range =  CORRESPONDING #( ls_filter-range ).
            WHEN 'KUNNR'.
              s_kunnr = CORRESPONDING #( ls_filter-range ).
            WHEN 'KTOKD'.
              s_ktokd = CORRESPONDING #( ls_filter-range ).
            WHEN 'DKONT'.
              s_dkont = CORRESPONDING #( ls_filter-range ).
            WHEN 'VKN_CR'.
              s_vkn_cr = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_SELK'.
              lt_p_selk_range =  CORRESPONDING #( ls_filter-range ).
            WHEN 'LIFNR'.
              s_lifnr = CORRESPONDING #( ls_filter-range ).
            WHEN 'KTOKK'.
              s_ktokk = CORRESPONDING #( ls_filter-range ).
            WHEN 'KKONT'.
              s_kkont = CORRESPONDING #( ls_filter-range ).
            WHEN 'BRSCH1'.
              s_brsch1 = CORRESPONDING #( ls_filter-range ).
            WHEN 'BRSCH2'.
              s_brsch2 = CORRESPONDING #( ls_filter-range ).
            WHEN 'VKN_VE'.
              s_vkn_ve = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_TRAN'.
              lt_p_tran_range = CORRESPONDING #( ls_filter-range ).

            WHEN 'P_ALL'.
              lt_p_all_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_BLIST'.
              lt_p_blist_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_DIFF'.
              lt_p_diff_range = CORRESPONDING #( ls_filter-range ).

*Çıktı İşlemleri

            WHEN 'P_LAST'.
              lt_p_last_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_CRED'.
              lt_p_cred_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_PRINT'.
              lt_p_print_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'LIMIT'.
              lt_limit_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_SHK'.
              lt_p_shk_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_DATE'.
              lt_p_date_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_BLI'.
              lt_p_bli_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_BSIZ'.
              lt_p_bsiz_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_EXCH'.
              lt_p_exch_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_ZERO'.
              lt_p_zero_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_SGLI'.
              lt_p_sgli_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'S_SGLI'.
              s_sgli = CORRESPONDING #( ls_filter-range ).
            WHEN 'S_OG'.
              s_og = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_NOVL'.
              lt_p_novl_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'P_NOLC'.
              lt_p_nolc_range = CORRESPONDING #( ls_filter-range ).

            WHEN 'S_SMKOD'.
              s_smkod = CORRESPONDING #( ls_filter-range ).

            WHEN 'S_SALMA'.
              s_salma = CORRESPONDING #( ls_filter-range ).

            WHEN 'P_EK'.
              lt_p_ek_alan = CORRESPONDING #( ls_filter-range ).

          ENDCASE.
        ENDLOOP.

        p_period = VALUE #( lt_period_range[ 1 ]-low OPTIONAL ).
        p_gjahr  = VALUE #( lt_gjahr_range[ 1 ]-low OPTIONAL ).
        p_daily  = VALUE #( lt_daily_range[ 1 ]-low OPTIONAL ).
        p_rdate  = VALUE #( lt_p_rdate_range[ 1 ]-low OPTIONAL ).
        p_gsber  = VALUE #( lt_p_gsber_range[ 1 ]-low OPTIONAL ).
        p_waers  = VALUE #( lt_p_waers_range[ 1 ]-low OPTIONAL ).
        p_seld   = VALUE #( lt_p_seld_range[ 1 ]-low OPTIONAL ).
        p_selk   = VALUE #( lt_p_selk_range[ 1 ]-low OPTIONAL ).
        p_print   = VALUE #( lt_p_print_range[ 1 ]-low OPTIONAL ).
        p_limit   = VALUE #( lt_limit_range[ 1 ]-low OPTIONAL ).
        p_shk   = VALUE #( lt_p_shk_range[ 1 ]-low OPTIONAL ).
        p_date   = VALUE #( lt_p_date_range[ 1 ]-low OPTIONAL ).
        p_bli   = VALUE #( lt_p_bli_range[ 1 ]-low OPTIONAL ).
        p_bsiz   = VALUE #( lt_p_bsiz_range[ 1 ]-low OPTIONAL ).
        p_exch   = VALUE #( lt_p_exch_range[ 1 ]-low OPTIONAL ).
        p_zero   = VALUE #( lt_p_zero_range[ 1 ]-low OPTIONAL ).
        p_sgli   = VALUE #( lt_p_sgli_range[ 1 ]-low OPTIONAL ).
        p_novl   = VALUE #( lt_p_novl_range[ 1 ]-low OPTIONAL ).
        p_nolc   = VALUE #( lt_p_nolc_range[ 1 ]-low OPTIONAL ).
        p_tran   = VALUE #( lt_p_tran_range[ 1 ]-low OPTIONAL ).
        p_ek = VALUE #( lt_p_ek_alan[ 1 ]-low OPTIONAL ).
*START-OF-SELECTION.
        sos(  ).


        DATA: lv_uuid     TYPE sysuuid_c22,
              ls_prev_key TYPE  zreco_cform,
              lv_posnr    TYPE int4.

        SORT gt_out_c BY hesap_tur hesap_no kunnr lifnr.

        LOOP AT gt_out_c ASSIGNING FIELD-SYMBOL(<fs_data>).

          " Eğer key değiştiyse yeni UUID oluştur
          IF <fs_data>-hesap_tur <> ls_prev_key-hesap_tur
             OR <fs_data>-hesap_no  <> ls_prev_key-hesap_no
             OR <fs_data>-kunnr     <> ls_prev_key-kunnr
             OR <fs_data>-lifnr     <> ls_prev_key-lifnr
             OR <fs_data>-umskz     <> ls_prev_key-umskz.
            TRY.
                lv_uuid = cl_system_uuid=>create_uuid_c22_static( ).

              CATCH cx_root INTO DATA(lx_err)..
            ENDTRY..
            ls_prev_key = <fs_data>. " key değerini sakla
          ENDIF.

          <fs_data>-uuid = lv_uuid.
          lv_posnr = lv_posnr + 1.
          <fs_data>-posnr = lv_posnr.
        ENDLOOP.


        DATA : ls_temp TYPE zreco_gtout,
               lt_temp TYPE TABLE OF zreco_gtout.

        LOOP AT gt_out_c INTO DATA(ls_out_c) .

          MOVE-CORRESPONDING ls_out_c TO ls_output.
          ls_output-gjahr = p_gjahr.
          ls_output-period = p_period.
          ls_output-bukrs = gs_adrs-bukrs.
          APPEND ls_output TO lt_output.
          MOVE-CORRESPONDING ls_out_c TO ls_temp.
          ls_temp-gjahr = p_gjahr.
          ls_temp-period = p_period.
          ls_temp-bukrs = gs_adrs-bukrs.
          ls_temp-nolocal = gv_no_local.
          APPEND ls_temp TO lt_temp.
        ENDLOOP.

*        DATA: lv_uuid     TYPE sysuuid_c22,
*              ls_prev_key TYPE  zreco_cform.
*
*        SORT gt_out_c BY hesap_tur hesap_no kunnr lifnr.
*
*        LOOP AT gt_out_c INTO ls_out_c.
*
*          " Eğer key değiştiyse yeni UUID oluştur
*          IF ls_out_c-hesap_tur <> ls_prev_key-hesap_tur
*             OR ls_out_c-hesap_no  <> ls_prev_key-hesap_no
*             OR ls_out_c-kunnr     <> ls_prev_key-kunnr
*             OR ls_out_c-lifnr     <> ls_prev_key-lifnr.
*
*            lv_uuid = cl_system_uuid=>create_uuid_c22_static( ).
*            ls_prev_key = ls_out_c. " key değerini sakla
*          ENDIF.
*
*          " UUID'yi ata ve temp tabloya ekle
*          MOVE-CORRESPONDING ls_out_c TO ls_temp.
*          ls_temp-uuid = lv_uuid.
*          APPEND ls_temp TO lt_temp.
*
*        ENDLOOP.

        DELETE FROM zreco_gtout.
        IF lt_temp IS NOT INITIAL.
          MODIFY zreco_gtout FROM TABLE @lt_temp.
        ENDIF.

        SELECT
            out~*
            , sup~supplier AS supplier
          FROM @lt_output AS out
          INNER JOIN i_suppliercompany AS sup
            ON sup~companycode = out~bukrs
           AND sup~supplier    = out~akont
           AND sup~accountingclerk = '01'
          INTO TABLE @DATA(lt_joined).

        LOOP AT lt_joined ASSIGNING FIELD-SYMBOL(<ls_del>).

          DELETE lt_output WHERE akont = <ls_del>-supplier.

        ENDLOOP.

        SELECT *
              FROM @lt_output AS output
              ORDER BY output~akont
              INTO CORRESPONDING FIELDS OF
                    TABLE @lt_output_detail
                   UP TO @lv_top ROWS
              OFFSET @lv_skip.

        SELECT COUNT( * ) FROM @lt_output AS detail
          INTO @DATA(lv_cnt_detail).
        DATA(lt_sorted) = io_request->get_sort_elements(  ).
        LOOP AT lt_sorted INTO DATA(ls_sort).
          lv_field = ls_sort-element_name.
          IF ls_sort-descending = abap_true.
            SORT lt_output_detail BY (lv_field) DESCENDING.
          ELSE.
            SORT lt_output_detail BY (lv_field) ASCENDING.
          ENDIF.
        ENDLOOP.
        io_response->set_data( lt_output_detail ).

        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lv_cnt_detail ).
        ENDIF.


      CATCH cx_rap_query_filter_no_range.
    ENDTRY.


  ENDMETHOD.