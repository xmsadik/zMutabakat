  METHOD single_sending.

    DATA : lv_tabix TYPE int4.
    DATA : lt_temp TYPE TABLE OF zreco_gtout.

    DATA(lt_cform) = it_cform[].

    CLEAR : gt_email, gt_mail_list.

    SELECT *
      FROM zreco_gtout
      FOR ALL ENTRIES IN @lt_cform
      WHERE uuid = @lt_cform-uuid
      INTO TABLE @gt_out_c.



    LOOP AT gt_out_c INTO DATA(ls_out_C).
      MOVE-CORRESPONDING ls_out_C TO gs_cform.
      COLLECT gs_cform INTO gt_cform.
    ENDLOOP.



    SELECT  * FROM zreco_adrs
    FOR ALL ENTRIES IN @gt_out_c
  WHERE bukrs EQ @gt_out_c-bukrs
    AND gsber EQ @gt_out_c-gsber
   INTO TABLE @gt_adrs.

    gs_adrs = VALUE #(  gt_adrs[ 1 ] OPTIONAL ).


    MOVE-CORRESPONDING gt_out_c TO lt_temp.
    DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING               hesap_tur
             hesap_no
             kunnr
             lifnr     .

    LOOP AT lt_temp ASSIGNING FIELD-SYMBOL(<fs_temp>).


      CLEAR :gs_mail_list,gs_receivers, gt_receivers.

      zreco_to_mail_adrs(
        EXPORTING
            i_bukrs      = gs_adrs-bukrs
            i_ucomm      = ''
            i_kunnr      = <fs_temp>-kunnr
            i_lifnr      = <fs_temp>-lifnr
            i_abtnr      = ''
            i_pafkt      = ''
            i_remark     = ''
            i_all        = ''
            i_stcd1      = <fs_temp>-vkn_tckn
            i_no_general = gs_adrs-no_general
            i_mtype      = 'C'
        IMPORTING
           e_mail       = <fs_temp>-email
           t_receivers  = gt_receivers
      ).





      LOOP AT gt_receivers INTO gs_receivers.
        lv_tabix = lv_tabix + 1.

        MOVE-CORRESPONDING <fs_temp> TO gs_mail_list.
        MOVE-CORRESPONDING gs_receivers TO gs_mail_list.

        gs_mail_list-bukrs = gs_adrs-bukrs.
        gs_mail_list-monat = <fs_temp>-period.
        gs_mail_list-gjahr = <fs_temp>-gjahr.
        gs_mail_list-posnr = lv_tabix.

        INSERT gs_mail_list INTO TABLE gt_mail_list.
      ENDLOOP.


      LOOP AT gt_cform INTO DATA(ls_cform).

        LOOP AT gt_mail_list INTO gs_mail_list WHERE kunnr EQ ls_cform-kunnr
                           AND lifnr EQ ls_cform-lifnr.
          gs_email-email = gs_mail_list-receiver.
          APPEND gs_email TO gt_email.
        ENDLOOP.

      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.