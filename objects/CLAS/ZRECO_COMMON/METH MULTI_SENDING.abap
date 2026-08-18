  METHOD multi_sending.

    DATA : lv_spras TYPE sy-langu.
    DATA(lt_cform) = it_cform[].

    single_sending( it_cform = lt_cform ).




    SELECT *
      FROM zreco_htxt
      INTO TABLE @DATA(gt_htxt).

    DATA(lv_bukrs) = VALUE #( gt_out_c[ 1 ]-bukrs OPTIONAL ).


    SELECT SINGLE *
             FROM zreco_adrs
            WHERE bukrs EQ @lv_bukrs
           INTO @gs_adrs.

    SELECT SINGLE companycode AS bukrs , Currency AS waers  FROM i_companycode WHERE CompanyCode  EQ @gs_adrs-bukrs INTO @DATA(ls_t001).



    LOOP AT gt_cform INTO gs_cform.

      CLEAR: gs_cform_sf, gs_exch, gt_cform_sf[], gt_cform_sf.
*
      CLEAR: gs_account, gv_loc_dmbtr, gv_spl_dmbtr, gv_kur.

*        IF p_waers IS INITIAL.

      LOOP AT gt_out_c INTO DATA(gs_out_c) WHERE hesap_tur EQ gs_cform-hesap_tur
                                             AND hesap_no EQ gs_cform-hesap_no
                                             AND kunnr EQ gs_cform-kunnr
                                             AND lifnr EQ gs_cform-lifnr.
        IF gs_account IS INITIAL.
          MOVE-CORRESPONDING gs_out_c TO gs_account.
        ENDIF.


        lv_spras = 'T'.

        READ TABLE gt_htxt INTO DATA(gs_htxt)
        WITH KEY bukrs = gs_out_c-bukrs
                 spras = 'T'"lv_spras "gs_account-spras  "  'mutabakat dili için land1(ülke)'
                 mtype = 'C'
                 ftype = '01'.

        MOVE-CORRESPONDING gs_out_c TO gs_cform_sf.

        IF gs_cform_sf-wrbtr GE 0.
          gs_cform_sf-debit_credit = gs_htxt-debit_text.
        ENDIF.

        IF gs_cform_sf-wrbtr LT 0.
          gs_cform_sf-debit_credit = gs_htxt-credit_text.
        ENDIF.

        IF gs_out_c-xsum IS NOT INITIAL.
          gv_loc_dmbtr = gv_loc_dmbtr + gs_cform_sf-dmbtr.
        ENDIF.

        IF gs_out_c-xsum IS INITIAL.
          gv_spl_dmbtr = gv_spl_dmbtr + gs_cform_sf-dmbtr.
        ENDIF.

        IF gs_out_c-kursf NE 0.
          READ TABLE gt_exch INTO gs_exch WITH KEY waers = gs_out_c-waers.
          IF sy-subrc NE 0.
            gs_exch-buzei = 1.
            gs_exch-hwaer = ls_t001-waers.
            gs_exch-kursf = gs_out_c-kursf.
            gs_exch-waers = gs_out_c-waers.
            gv_kur = 'X'.
            APPEND gs_exch TO gt_exch.
          ENDIF.
        ENDIF.

        IF gs_out_c-no_local_curr IS NOT INITIAL.
          CLEAR: gs_cform_sf-waers, gs_cform_sf-waers_c.
        ENDIF.

        IF gs_cform_sf-waers EQ 'JPY'.
          gs_cform_sf-wrbtr = gs_cform_sf-wrbtr / 10.
        ENDIF.

        APPEND gs_cform_sf TO gt_cform_sf.

      ENDLOOP.
*

      "YiğitcanÖzdemir 08072025 iş alanı collect

      DATA : lt_cform_sf TYPE TABLE OF zreco_cform_sform,
             ls_cform_sf TYPE zreco_cform_sform.

      FIELD-SYMBOLS : <fs_cform_sf> TYPE zreco_cform_sform.

      "birden fazla iş alanı olduğunda takip raporuna düşmediği için gsber alanı clearlandı.
      LOOP AT gt_cform_sf ASSIGNING <fs_cform_sf>.
        CLEAR <fs_cform_sf>-gsber.
      ENDLOOP.


      print_form( iv_output ).

      IF gv_subrc EQ 0  AND iv_output IS NOT INITIAL.
        gs_out_c-xsuccessful = 'X'.
*          IF p_waers IS INITIAL.
        MODIFY gt_out_c FROM gs_out_c TRANSPORTING xsuccessful
        WHERE hesap_no EQ gs_cform-hesap_no
        AND hesap_tur EQ gs_cform-hesap_tur
        AND kunnr EQ gs_cform-kunnr
        AND lifnr EQ gs_cform-lifnr.
*      ELSE.
*        MODIFY gt_out_c FROM gs_out_c TRANSPORTING xsuccessful
*        WHERE hesap_no EQ gs_cform-hesap_no
*        AND hesap_tur EQ gs_cform-hesap_tur
*        AND kunnr EQ gs_cform-kunnr
*        AND lifnr EQ gs_cform-lifnr
*        AND waers EQ gs_cform-waers.
      ENDIF.


    ENDLOOP.

* Başarılı olanları listeden sil
*    IF iv_output IS NOT INITIAL.
*      DELETE gt_out_b WHERE xsuccessful EQ 'X'.
    DELETE gt_out_c WHERE xsuccessful EQ 'X'.
*    ENDIF.

    IF gv_pdf IS NOT INITIAL.
      ev_pdf = gv_pdf.
    ENDIF.


  ENDMETHOD.