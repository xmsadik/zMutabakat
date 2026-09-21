  METHOD zreco_get_balance.

    DATA: gt_out_c TYPE TABLE OF zreco_cform,
          gs_out_c TYPE zreco_cform.

*    DATA : r_bukrs TYPE RANGE OF bsid_view,
*           r_kunnr TYPE RANGE OF bsid-kunnr,
*           r_lifnr TYPE RANGE OF bsik-lifnr.

    DATA: lv_seld TYPE abap_boolean,
          lv_selk TYPE abap_boolean,
          lv_exch TYPE abap_boolean.

    CHECK i_bukrs IS NOT INITIAL.

    CLEAR: gt_out_c[], et_cform[]. "r_kunnr[], r_lifnr[].

    IF i_bukrs IS NOT INITIAL.
*      r_bukrs-sign = 'I'.
*      r_bukrs-option = 'EQ'.
*      r_bukrs-low = i_bukrs.
*      APPEND r_bukrs.
    ENDIF.

    IF i_kunnr IS NOT INITIAL.
*      r_kunnr-sign = 'I'.
*      r_kunnr-option = 'EQ'.
*      r_kunnr-low = i_kunnr.
*      APPEND r_kunnr.
      lv_seld = 'X'.
    ENDIF.

    IF i_lifnr IS NOT INITIAL.
*      r_lifnr-sign = 'I'.
*      r_lifnr-option = 'EQ'.
*      r_lifnr-low = i_lifnr.
*      APPEND r_lifnr.
      lv_selk = 'X'.
    ENDIF.

    IF i_kurst IS NOT INITIAL.
      lv_exch = 'X'.
    ENDIF.

* Madde 4 - Hesap türü/tanımı ALV-PDF'de boş geliyordu, canlı veri üretmiyordu fix - D_BOZKAYNAK
* NOT: SUBMIT ... AND RETURN + IMPORT FROM MEMORY deseni ABAP Cloud/RAP
* mimarisinde desteklenmez. zcl_reco_form=>if_rap_query_provider~select
* zaten aynı verinin materyalize edilmiş halini ZRECO_GTOUT tablosuna
* yazıyor; bu metot da aynı kaynaktan okumalı.
    IF lv_seld EQ 'X'.
      SELECT * FROM zreco_gtout
        WHERE bukrs     EQ @i_bukrs
          AND period    EQ @i_monat
          AND gjahr     EQ @i_gjahr
          AND hesap_tur EQ 'M'
          AND hesap_no  EQ @i_kunnr
        INTO CORRESPONDING FIELDS OF TABLE @gt_out_c.
    ELSEIF lv_selk EQ 'X'.
      SELECT * FROM zreco_gtout
        WHERE bukrs     EQ @i_bukrs
          AND period    EQ @i_monat
          AND gjahr     EQ @i_gjahr
          AND hesap_tur EQ 'S'
          AND hesap_no  EQ @i_lifnr
        INTO CORRESPONDING FIELDS OF TABLE @gt_out_c.
    ELSE.
      SELECT * FROM zreco_gtout
        WHERE bukrs  EQ @i_bukrs
          AND period EQ @i_monat
          AND gjahr  EQ @i_gjahr
        INTO CORRESPONDING FIELDS OF TABLE @gt_out_c.
    ENDIF.

    LOOP AT gt_out_c INTO gs_out_c.

      APPEND INITIAL LINE TO et_cform ASSIGNING FIELD-SYMBOL(<lfs_cform>).

      MOVE-CORRESPONDING gs_out_c TO <lfs_cform>.

      IF gs_out_c-xsum IS NOT INITIAL.
        e_dmbtr = e_dmbtr + gs_out_c-dmbtr.
      ENDIF.

*      APPEND et_cform.

      CLEAR: gs_out_c, et_cform.

    ENDLOOP.
  ENDMETHOD.