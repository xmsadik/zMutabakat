  METHOD zreco_pdf_preview.

    DATA: ls_h001       TYPE zreco_hdr,
          lt_h001       TYPE TABLE OF zreco_hdr,
          lv_only_loc   TYPE abap_boolean,
          lv_line       TYPE int2,
          lv_repeat     TYPE int2,
          lc_repeat     TYPE char05,
          lv_screen     TYPE abap_boolean,
          lv_subject    TYPE string,
          ls_result     TYPE zreco_soodk,
          ls_remd       TYPE zreco_rmd,
          lt_remd       TYPE TABLE OF zreco_rmd,
          lt_cform      TYPE TABLE OF zreco_rcai,
          lt_cdun       TYPE TABLE OF zreco_cdun,
          ls_cdun       TYPE zreco_cdun,
          lv_tcount     TYPE int4,
          lv_count      TYPE int4,
          lt_save_files TYPE zreco_tt_down_files,
          ls_save_files TYPE zreco_s_down_files,
          lv_xstring    TYPE xstring,
          lv_lenght     TYPE i,
          lt_lines      TYPE TABLE OF zreco_tline,
          lt_line       TYPE TABLE OF zreco_tline,
          lv_tdname     TYPE char72.

    DATA: BEGIN OF lt_temp,
            ltext TYPE text100,
          END OF lt_temp.


    DATA: gs_doc_info        TYPE zreco_ssfcrespd,                           "DMBAYEL commentlenmiştir
          gs_job_info        TYPE zreco_ssfcrescl,
*          gs_job_options    TYPE ssfcresop,
          gs_control_options TYPE zreco_ssfctrlop,
          gs_output_options  TYPE zreco_ssfcompop,
          gv_sf_name         TYPE char72,   "Smartform adı
          gv_fm_name         TYPE char72. "Fonksiyon adı
*          gv_otf            TYPE abap_boolean.

    DATA: gs_adrs  TYPE zreco_adrs, "Şirket adres bilgileri
          gt_tole  TYPE TABLE OF zreco_tole, "Vkn bazında tolerason
          gt_text  TYPE TABLE OF zreco_text, "Başlık metinleri
          gs_text  TYPE zreco_text, "Mutabakat web iletileri
          gs_htxt  TYPE zreco_htxt, "Mutabakat form metinleri
          gt_htxt  TYPE TABLE OF zreco_htxt, "Başlık metinleri
          gs_dtxt  TYPE zreco_dtxt, "Ihtar form metinleri
          gt_dtxt  TYPE TABLE OF zreco_dtxt, "Ihtar form metinleri
          gs_otxt  TYPE zreco_otxt, "Açık kalem metinleri
          gt_otxt  TYPE TABLE OF zreco_otxt, "Açık kalem metinleri
          gt_atxt  TYPE TABLE OF zreco_atxt, "Hesap metinleri
          gt_gsbr  TYPE SORTED TABLE OF zreco_gsbr
                   WITH NON-UNIQUE KEY gsber, "İş alanı tanımları
          gs_gsbr  TYPE zreco_gsbr,
          gs_atxt  TYPE zreco_atxt,
          gs_adrc  TYPE zreco_ddl_i_address2,
          gt_adrc  TYPE TABLE OF zreco_ddl_i_address2,
          gt_flds  TYPE TABLE OF zreco_flds,
          gs_flds  TYPE zreco_flds,
          gs_parm  TYPE zreco_parm,
          gt_uname TYPE TABLE OF zreco_unam.

    DATA: gt_bank TYPE TABLE OF zreco_bank.

    DATA: gt_h001      TYPE SORTED TABLE OF zreco_hdr
                     WITH NON-UNIQUE KEY bukrs mnumber monat gjahr
                                     hesap_tur hesap_no
          , "Gönderim başlık verisi
          gs_h001      TYPE zreco_hdr,
          gt_h002      TYPE SORTED TABLE OF zreco_hia
                       WITH NON-UNIQUE KEY bukrs mnumber monat gjahr
                                       hesap_tur hesap_no
          , "Cevap başlık verisi
          gs_h002      TYPE zreco_hia,
          gt_w001      TYPE SORTED TABLE OF zreco_rboc
                       WITH NON-UNIQUE KEY bukrs mnumber monat gjahr
                                       hesap_tur hesap_no
          , "Gönderim PB bazında bilgiler
          gs_w001      TYPE zreco_rboc,
          gt_v001      TYPE SORTED TABLE OF zreco_vers
                       WITH NON-UNIQUE KEY bukrs mnumber monat gjahr,
          gs_v001      TYPE zreco_vers, "Versiyon
          gt_b001      TYPE SORTED TABLE OF zreco_recb
                       WITH NON-UNIQUE KEY bukrs mnumber monat gjahr
                                           kunnr lifnr
          ,
          gs_b001      TYPE zreco_recb,
          gt_c001      TYPE SORTED TABLE OF zreco_rcai
                       WITH NON-UNIQUE KEY bukrs mnumber monat gjahr
                                           kunnr lifnr waers
          ,
          gs_c001      TYPE zreco_rcai,
          gt_e001      TYPE SORTED TABLE OF zreco_refi
                       WITH NON-UNIQUE KEY bukrs mnumber monat gjahr
                                           hesap_tur hesap_no
          ,
          gs_e001      TYPE zreco_refi,
          gt_e002      TYPE SORTED TABLE OF zreco_urei
                       WITH NON-UNIQUE KEY receiver
          ,
          gt_e003      TYPE SORTED TABLE OF zreco_eate
                       WITH NON-UNIQUE KEY smtp_addr
          ,
          gs_e002      TYPE zreco_urei,
          gs_d002      TYPE zreco_dsdr, "Şüpheli alacaklar
          gt_r000      TYPE SORTED TABLE OF zreco_reia
                       WITH NON-UNIQUE KEY mnumber monat gjahr version,
          gs_r000      TYPE zreco_reia,
          gt_r001      TYPE SORTED TABLE OF zreco_rcar
                       WITH NON-UNIQUE KEY mnumber monat gjahr version,
          gs_r001      TYPE zreco_rcar,
          gt_r002      TYPE SORTED TABLE OF zreco_rbia
                       WITH NON-UNIQUE KEY mnumber monat gjahr version,
          gt_user      TYPE SORTED TABLE OF zreco_cvua
                       WITH NON-UNIQUE KEY kunnr lifnr,
          gs_user      TYPE zreco_cvua,
          gs_r002      TYPE zreco_rbia,
          gv_bukrs     TYPE bukrs, "Şirket kodu
          gv_spras     TYPE spras, "İletişim dili
          gv_langu     TYPE spras VALUE 'T', "Ekran iletişim dili
          gv_auth      TYPE abap_boolean,  "Yetki kontrolü
          gv_odk       TYPE abap_boolean,  "ÖDK mutabakatı da var
          gv_kur       TYPE abap_boolean,  "Kur var
          gv_loc_dmbtr TYPE zreco_tslxx12, "Toplam UPB tutarı
          gv_spl_dmbtr TYPE zreco_tslxx12. "Toplam ÖDK tutarı

    DATA:  gt_taxm TYPE SORTED TABLE OF zreco_taxm
                   WITH NON-UNIQUE KEY kunnr lifnr,
           gs_taxm TYPE zreco_taxm.

    DATA:  gv_mail_send  TYPE abap_boolean.

    DATA  : gv_first_date TYPE d, "Dönem ilk tarih
            gv_last_date  TYPE d, "Dönem son tarih
            gv_send       TYPE abap_boolean, "Gönderim yapılmış
            gv_mnumber    TYPE zreco_number,
            gv_b_sel      TYPE zreco_date_selection,
            "B formu tarih seçimi
            gv_c_sel      TYPE zreco_date_selection.

    DATA: gt_cform_sf TYPE TABLE OF zreco_cform_sform,
          gs_cform_sf TYPE zreco_cform_sform.

*<--- E-mail gereki tanımlamalar
    DATA: gt_receivers           TYPE TABLE OF zreco_somlreci1,
          gs_receivers           TYPE zreco_somlreci1,
          gt_mail_list           TYPE SORTED TABLE OF zreco_tmpe
                                 WITH NON-UNIQUE KEY kunnr lifnr receiver,
          gs_mail_list           LIKE LINE OF gt_mail_list,
          gt_body                TYPE TABLE OF zreco_solisti1,
          gv_subject             TYPE string, "Mail konusu
          gv_obj_descr           TYPE char72, "SOST doküman adı
          gv_attach_name         TYPE char72, "Ek adı
          gv_sender_name         TYPE char256, "Gönderen adı
          gv_sender_address      TYPE zreco_ad_smtpadr, "Gönderen adresi
          gv_from_adress         TYPE char256,
          gv_sender_address_type TYPE char05,
          gs_return              TYPE bapiret2.

    TYPES: BEGIN OF ty_cform,
             hesap_tur TYPE zreco_account_type,
             hesap_no  TYPE zreco_ktonr_av,
             waers     TYPE waers,
             kunnr     TYPE kunnr,
             lifnr     TYPE lifnr,
           END OF ty_cform.

* Cari mutabakat ALV veri
    DATA: gt_out_c         TYPE TABLE OF zreco_cform,
          gs_out_c         TYPE zreco_cform,
* Cari mutabakat geçici veri
          gt_cform_temp    TYPE TABLE OF zreco_cform_temp,
          gs_cform_temp    TYPE zreco_cform_temp,

          gt_cform         TYPE TABLE OF ty_cform  , "Seçim için
          gs_cform         TYPE ty_cform,

          gt_exch          TYPE TABLE OF zreco_exch,
          gs_exch          TYPE zreco_exch,
          gt_dunning       TYPE TABLE OF zreco_dunning,
          gs_dunning       TYPE zreco_dunning,
          gt_cdun          TYPE SORTED TABLE OF zreco_cdun WITH NON-UNIQUE KEY bukrs gjahr hesap_no belnr buzei,
          gs_cdun          TYPE zreco_cdun,
          gt_dunning_times TYPE TABLE OF zreco_dunning_times,
          gs_dunning_times TYPE zreco_dunning_times,
          gt_opening       TYPE TABLE OF zreco_opening,
          gs_opening       TYPE zreco_opening,
          gt_language      TYPE SORTED TABLE OF zreco_lang
                             WITH NON-UNIQUE KEY bukrs  .

* Mutabakat açık kalemler
    DATA : gt_bsid_temp TYPE TABLE OF zreco_tbsd,
           gs_bsid_temp TYPE zreco_tbsd.

    DATA: gt_note TYPE STANDARD TABLE OF zreco_note,
          gs_note TYPE zreco_note.

    DATA:gs_account TYPE zreco_account.
    DATA:gv_otf  TYPE abap_boolean.

    CLEAR:gs_output_options, gs_control_options, gs_job_info, gv_otf.

    CASE i_sort_indicator.
      WHEN '1'.
        SORT it_h001 BY mnumber.
      WHEN '2'.
        SORT it_h001 BY hesap_tur hesap_no.
      WHEN '3'.
        SORT it_h001 BY name1 AS TEXT.
      WHEN OTHERS.
    ENDCASE.

    READ TABLE it_h001 INTO ls_h001 INDEX 1.

    SELECT SINGLE * FROM i_companycode
    WHERE CompanyCode  EQ @ls_h001-bukrs
    INTO @DATA(ls_t001).

    SELECT SINGLE * FROM zreco_adrs
      WHERE bukrs EQ @ls_h001-bukrs
        AND gsber EQ @ls_h001-gsber
       INTO @gs_adrs.




    IF it_h001[] IS NOT INITIAL.

      CLEAR: gt_flds[], gt_htxt[], gt_dtxt[], gt_otxt[], gt_text[], gt_adrc[],
             gt_v001[], gt_c001[], gt_b001[], gt_r000[], gt_r001[], gt_r002[],
             gt_bank[], gt_e001[], gt_e002[], gt_e003[], gt_h002[].

      SELECT * FROM zreco_flds
        FOR ALL ENTRIES IN @it_h001
        WHERE hesap_tur EQ @it_h001-hesap_tur
        INTO TABLE @gt_flds.

      SELECT * FROM zreco_htxt
        FOR ALL ENTRIES IN @it_h001
        WHERE bukrs EQ @it_h001-bukrs
        AND spras   EQ @it_h001-spras
        AND mtype   EQ @it_h001-mtype
        AND ftype   EQ @it_h001-ftype
        INTO TABLE @gt_htxt.

      SELECT * FROM zreco_dtxt
        FOR ALL ENTRIES IN @it_h001
        WHERE bukrs EQ @it_h001-bukrs
        AND spras EQ @it_h001-spras
        AND ftype EQ @it_h001-ftype
        INTO TABLE @gt_dtxt.

      SELECT * FROM zreco_otxt
        FOR ALL ENTRIES IN @it_h001
        WHERE bukrs EQ @it_h001-bukrs
          AND spras EQ @it_h001-spras
          AND ftype EQ @it_h001-ftype
        INTO TABLE @gt_otxt.

      SELECT * FROM zreco_text
        FOR ALL ENTRIES IN @it_h001
        WHERE bukrs EQ @it_h001-bukrs
          AND gsber EQ @it_h001-gsber
          AND spras EQ @it_h001-spras
          AND hesap_tur EQ @it_h001-hesap_tur
        INTO TABLE @gt_text.

      SELECT * FROM zreco_ddl_i_address2
        FOR ALL ENTRIES IN @it_h001
        WHERE AddressID EQ @it_h001-adrnr
        INTO CORRESPONDING FIELDS OF TABLE @gt_adrc.

      SELECT * FROM zreco_hia
        FOR ALL ENTRIES IN @it_h001
          WHERE bukrs EQ @it_h001-bukrs
          AND gsber EQ @it_h001-gsber
          AND mnumber EQ @it_h001-mnumber
          AND monat EQ @it_h001-monat
          AND gjahr EQ @it_h001-gjahr
          AND hesap_tur EQ @it_h001-hesap_tur
          AND hesap_no EQ @it_h001-hesap_no
          INTO TABLE @gt_h002.

      SELECT * FROM zreco_vers
        FOR ALL ENTRIES IN @it_h001
        WHERE bukrs EQ @it_h001-bukrs
          AND gsber EQ @it_h001-gsber
          AND mnumber EQ @it_h001-mnumber
          AND monat  EQ @it_h001-monat
          AND gjahr  EQ @it_h001-gjahr
          AND vstatu EQ 'G'
        INTO TABLE @gt_v001.

      IF gt_v001[] IS NOT INITIAL.
        SELECT * FROM zreco_rcai
          FOR ALL ENTRIES IN @gt_v001
          WHERE bukrs EQ @gt_v001-bukrs
            AND gsber EQ @gt_v001-gsber
            AND mnumber EQ @gt_v001-mnumber
            AND monat EQ @gt_v001-monat
            AND gjahr EQ @gt_v001-gjahr
            AND version EQ @gt_v001-version
          INTO TABLE @gt_c001.

        SELECT * FROM zreco_recb
          FOR ALL ENTRIES IN @gt_v001
          WHERE bukrs EQ @gt_v001-bukrs
            AND gsber EQ @gt_v001-gsber
            AND mnumber EQ @gt_v001-mnumber
            AND monat EQ @gt_v001-monat
            AND gjahr EQ @gt_v001-gjahr
            AND version EQ @gt_v001-version
          INTO TABLE @gt_b001.

        SELECT * FROM zreco_reia
          FOR ALL ENTRIES IN @gt_v001
          WHERE bukrs EQ @gt_v001-bukrs
            AND gsber EQ @gt_v001-gsber
            AND mnumber EQ @gt_v001-mnumber
            AND monat EQ @gt_v001-monat
            AND gjahr EQ @gt_v001-gjahr
            AND version EQ @gt_v001-version
          INTO TABLE @gt_r000.

        SELECT * FROM zreco_rcar
          FOR ALL ENTRIES IN @gt_v001
          WHERE bukrs EQ @gt_v001-bukrs
            AND gsber EQ @gt_v001-gsber
            AND mnumber EQ @gt_v001-mnumber
            AND monat EQ @gt_v001-monat
            AND gjahr EQ @gt_v001-gjahr
            AND version EQ @gt_v001-version
          INTO TABLE @gt_r001.

        SELECT * FROM zreco_rbia
          FOR ALL ENTRIES IN @gt_v001
          WHERE bukrs EQ @gt_v001-bukrs
            AND gsber EQ @gt_v001-gsber
            AND mnumber EQ @gt_v001-mnumber
            AND monat EQ @gt_v001-monat
            AND gjahr EQ @gt_v001-gjahr
            AND version EQ @gt_v001-version
          INTO TABLE @gt_r002.

      ENDIF.

      IF i_mail_send IS NOT INITIAL.
        SELECT * FROM zreco_refi
          FOR ALL ENTRIES IN @it_h001
          WHERE bukrs EQ @it_h001-bukrs
            AND gsber EQ @it_h001-gsber
            AND mnumber EQ @it_h001-mnumber
            AND monat EQ @it_h001-monat
            AND gjahr EQ @it_h001-gjahr
            AND hesap_tur EQ @it_h001-hesap_tur
            AND hesap_no EQ @it_h001-hesap_no
            AND unsubscribe EQ ''
          INTO TABLE @gt_e001.

        SELECT * FROM zreco_urei
          FOR ALL ENTRIES IN @it_h001
          WHERE bukrs EQ @it_h001-bukrs
          AND gsber EQ @it_h001-gsber
          INTO TABLE @gt_e002.

        SELECT * FROM zreco_eate
          FOR ALL ENTRIES IN @it_h001
          WHERE bukrs EQ @it_h001-bukrs
          INTO TABLE @gt_e003.
      ENDIF.

    ENDIF.

* Banka bilgileri
    SELECT * FROM zreco_bank
      WHERE bukrs EQ @gs_adrs-bukrs
      INTO TABLE @gt_bank.

    lv_count = lines( it_h001 ).
    lv_count = 0.

    LOOP AT it_h001 INTO ls_h001.

      CLEAR: gs_flds, gs_htxt, gs_dtxt, gs_taxm, gs_adrc,
             gs_v001, et_return, gv_mail_send.

      lv_count = lv_count + 1.

      CONCATENATE ls_h001-gjahr ls_h001-monat '01' INTO gv_first_date.

      me->rp_last_day_of_months(
       EXPORTING
          day_in            = gv_first_date
        IMPORTING
          last_day_of_month = gv_last_date
*       EXCEPTIONS
*          day_in_no_date    = 1
      ).

* Versiyon
      READ TABLE gt_v001 INTO gs_v001
      WITH KEY bukrs = ls_h001-bukrs
               gsber = ls_h001-gsber
               mnumber = ls_h001-mnumber
               monat = ls_h001-monat
               gjahr = ls_h001-gjahr
               vstatu = 'G'.

* Form için kullanılan alanlar
      READ TABLE gt_flds INTO gs_flds
      WITH KEY hesap_tur = ls_h001-hesap_tur.

* Form metinleri
      READ TABLE gt_htxt INTO gs_htxt
      WITH KEY bukrs = ls_h001-bukrs
               spras = ls_h001-spras
               mtype = ls_h001-mtype
               ftype = ls_h001-ftype.

* İhtar metinleri
      READ TABLE gt_dtxt INTO gs_dtxt
      WITH KEY bukrs = ls_h001-bukrs
               spras = ls_h001-spras
               ftype = ls_h001-ftype.

* Açık kalem metinleri
      READ TABLE gt_otxt INTO gs_otxt
      WITH KEY bukrs = ls_h001-bukrs
               spras = ls_h001-spras
               ftype = ls_h001-ftype.

* Web ekran iletileri
      READ TABLE gt_text INTO gs_text
      WITH KEY bukrs = ls_h001-bukrs
               gsber = ls_h001-gsber
               spras = ls_h001-spras
               hesap_tur = ls_h001-hesap_tur.

* Web ekran iletileri

* Adres ve iletişim alanları
      MOVE-CORRESPONDING ls_h001 TO gs_adrc.

      READ TABLE gt_adrc INTO gs_adrc
      WITH KEY AddressID = ls_h001-adrnr.


      DATA: gs_temp TYPE  zreco_rcai. "YiğitcanÖzdemir

      LOOP AT gt_c001 INTO gs_c001 WHERE bukrs EQ gs_v001-bukrs
                                     AND gsber EQ gs_v001-gsber
                                     AND mnumber EQ gs_v001-mnumber
                                     AND monat EQ gs_v001-monat
                                     AND gjahr EQ gs_v001-gjahr
                                     AND version EQ gs_v001-version.

        CLEAR: lt_cform, gs_cform_sf.

        MOVE-CORRESPONDING ls_h001 TO gs_cform_sf.

        MOVE-CORRESPONDING gs_c001 TO gs_cform_sf.

        IF gs_cform_sf-wrbtr GE 0.
          gs_cform_sf-debit_credit = gs_htxt-debit_text.
        ENDIF.

        IF gs_cform_sf-wrbtr LT 0.
          gs_cform_sf-debit_credit = gs_htxt-credit_text.
        ENDIF.

        IF gs_c001-xsum IS NOT INITIAL.
          gv_loc_dmbtr = gv_loc_dmbtr + gs_cform_sf-dmbtr.
        ENDIF.

        IF gs_c001-xsum IS INITIAL.
          gv_spl_dmbtr = gv_spl_dmbtr + gs_cform_sf-dmbtr.
        ENDIF.

        IF gs_c001-kursf NE 0.
          READ TABLE gt_exch INTO gs_exch WITH KEY waers = gs_c001-waers.
          IF sy-subrc NE 0.
            gs_exch-buzei = 1.
*            gs_exch-hwaer = t001-waers.                                                "D_MBAYEL commentlenmiştir
            gs_exch-kursf = gs_c001-kursf.
            gs_exch-waers = gs_c001-waers.
            gv_kur = 'X'.
            APPEND gs_exch TO gt_exch.
          ENDIF.
        ENDIF.

        APPEND gs_c001 TO lt_cform. "YiğitcanÖzdemir
        MOVE-CORRESPONDING gt_c001 TO lt_cform.

        APPEND: gs_cform_sf TO gt_cform_sf.


        MOVE-CORRESPONDING gs_cform_sf TO gs_temp.
        APPEND gs_temp TO lt_cform.

      ENDLOOP.

      LOOP AT gt_r001 INTO gs_r001 WHERE bukrs EQ gs_v001-bukrs
                                     AND gsber EQ gs_v001-gsber
                                     AND mnumber EQ gs_v001-mnumber
                                     AND monat EQ gs_v001-monat
                                     AND gjahr EQ gs_v001-gjahr.

        LOOP AT gt_cform_sf INTO gs_cform_sf WHERE waers EQ gs_r001-waers AND xsum EQ 'X'.

          gs_cform_sf-dmbtr_c = gs_r001-dmbtr.
          gs_cform_sf-wrbtr_c = gs_r001-wrbtr.
          gs_cform_sf-waers_c = gs_r001-waers.

          IF gs_cform_sf-wrbtr_c GE 0.
            gs_cform_sf-debit_credit_c = gs_htxt-debit_text.
          ENDIF.

          IF gs_cform_sf-wrbtr_c LT 0.
            gs_cform_sf-debit_credit_c = gs_htxt-credit_text.
          ENDIF.

          MODIFY gt_cform_sf FROM gs_cform_sf.

        ENDLOOP.
      ENDLOOP.

      SORT gt_cform_sf BY ltext waers wrbtr .

* Cevap bilgileri
      LOOP AT gt_h002 INTO gs_h002 WHERE bukrs EQ gs_v001-bukrs
                                     AND gsber EQ gs_v001-gsber
                                     AND mnumber EQ gs_v001-mnumber
                                     AND monat EQ gs_v001-monat
                                     AND gjahr EQ gs_v001-gjahr.

        EXIT.

      ENDLOOP.

* İhtar kalemleri
      IF ls_h001-verzn IS NOT INITIAL.

        CLEAR: gt_bsid_temp[], gt_dunning[], gt_dunning_times ,
                 gt_cdun, lt_cdun.

        SELECT * FROM zreco_cdun
          WHERE bukrs EQ @ls_h001-bukrs
          AND hesap_tur EQ @ls_h001-hesap_tur
          AND hesap_no EQ @ls_h001-hesap_no
          INTO TABLE @gt_cdun.

        LOOP AT gt_cdun INTO gs_cdun.

          gs_dunning_times-hesap_no = gs_cdun-hesap_no.
          gs_dunning_times-belnr = gs_cdun-belnr.
          gs_dunning_times-buzei = gs_cdun-buzei.
          gs_dunning_times-bldat = gs_cdun-bldat.
          gs_dunning_times-count_dunning = 1.

          COLLECT gs_dunning_times INTO gt_dunning_times.

        ENDLOOP.

        SELECT * FROM zreco_tbsd
        WHERE bukrs EQ @ls_h001-bukrs
        AND p_monat EQ @ls_h001-monat
        AND p_gjahr EQ @ls_h001-gjahr
        AND hesap_tur EQ @ls_h001-hesap_tur
        AND hesap_no EQ @ls_h001-hesap_no
        AND ftype EQ @ls_h001-ftype
        INTO TABLE @gt_bsid_temp.

        LOOP AT gt_bsid_temp INTO gs_bsid_temp WHERE hesap_no EQ ls_h001-hesap_no.

          CLEAR: lt_cdun, gt_dunning.

          APPEND gs_bsid_temp TO gt_bsid_temp.
          APPEND ls_h001 TO lt_h001.
          MOVE-CORRESPONDING gt_bsid_temp TO lt_cdun.
          MOVE-CORRESPONDING lt_h001 TO lt_cdun.

          ls_cdun-gjahr_b = gs_bsid_temp-gjahr.
          ls_cdun-verzn = gs_bsid_temp-verzn.
          ls_cdun-mdatum = cl_abap_context_info=>get_system_date( ).

          MOVE-CORRESPONDING gs_cdun TO gs_dunning.

          COLLECT: gs_cdun INTO lt_cdun,
                   gs_dunning INTO gt_dunning.

        ENDLOOP.

        LOOP AT gt_dunning INTO gs_dunning.

          CLEAR gs_dunning_times.

          READ TABLE gt_dunning_times INTO gs_dunning_times
          WITH KEY hesap_no = ls_h001-hesap_no
                   belnr    = gs_dunning-belnr
                   bldat    = gs_dunning-bldat.

          gs_dunning-count_dunning = gs_dunning_times-count_dunning + 1.

          MODIFY gt_dunning FROM gs_dunning.

        ENDLOOP.

        SORT gt_dunning BY verzn DESCENDING.

      ENDIF.

      IF ls_h001-xopen IS NOT INITIAL.

        CLEAR: gt_bsid_temp[], gt_opening[].

        SELECT * FROM zreco_tbsd
          WHERE bukrs EQ @ls_h001-bukrs
          AND p_monat EQ @ls_h001-monat
          AND p_gjahr EQ @ls_h001-gjahr
          AND hesap_tur EQ @ls_h001-hesap_tur
          AND hesap_no EQ @ls_h001-hesap_no
          AND ftype EQ @ls_h001-ftype
          INTO TABLE @gt_bsid_temp.

        LOOP AT gt_bsid_temp INTO gs_bsid_temp WHERE hesap_no EQ ls_h001-hesap_no.

          CLEAR gt_opening.

          MOVE-CORRESPONDING gs_bsid_temp TO gs_opening.
          MOVE-CORRESPONDING ls_h001 TO gs_opening.

          IF gs_bsid_temp-verzn GT 0.
            gs_opening-verzn = gs_bsid_temp-verzn.
          ENDIF.

          COLLECT gs_opening INTO gt_opening.

        ENDLOOP.

        SORT gt_opening BY budat netdt.

      ENDIF.

      CLEAR: gv_odk, lv_only_loc.

* Gönderen iletişim bilgileri

      me->zreco_contact_m(
      EXPORTING
           is_adrs     = gs_adrs
          i_hesap_tur = ls_h001-hesap_tur
          i_hesap_no  = ls_h001-hesap_no
          i_ktokl     = ls_h001-ktokl
          i_mtype     = ls_h001-mtype
          i_ftype     = ls_h001-ftype
          i_uname     = gs_v001-ernam
      IMPORTING
          e_name      = gs_adrs-m_name
          e_telefon   = gs_adrs-m_telefon
          e_email     = gs_adrs-m_email
        ).

      IF gv_spl_dmbtr NE 0.
        gv_odk = 'X'.
      ENDIF.

      LOOP AT gt_cform_sf INTO gs_cform_sf WHERE xsum EQ 'X'.
*                           AND waers EQ t001-waers.                                    "D_MBAYEL commentlenmiştir
        lv_only_loc = 'X'.
        EXIT.
      ENDLOOP.

      LOOP AT gt_cform_sf INTO gs_cform_sf WHERE xsum EQ 'X'.                            "D_MBAYEL commentlenmiştir
*                           AND waers NE t001-waers.
        CLEAR lv_only_loc .
        EXIT.
      ENDLOOP.

      CLEAR: lt_line[], gt_note[].

      CLEAR lv_tdname.

      CONCATENATE 'ZRECO' ls_h001-bukrs ls_h001-mnumber
      INTO lv_tdname.


      IF sy-subrc EQ 0.
        LOOP AT lt_line ASSIGNING FIELD-SYMBOL(<lfs_line>).
          gs_note-line = <lfs_line>-tdline.
          APPEND gs_note TO gt_note.
        ENDLOOP.
      ENDIF.

      CLEAR: gs_r000, gs_job_info.

      READ TABLE gt_r000 INTO gs_r000 WITH KEY bukrs = ls_h001-bukrs
                                               gsber = ls_h001-gsber
                                               mnumber = ls_h001-mnumber
                                               monat = ls_h001-monat
                                               gjahr = ls_h001-gjahr
                                              version = gs_v001-version.

      IF i_down IS NOT INITIAL.
        "Ayrı dosya indirecek veya çoklu dosyada son dosya ise KAPAT
        IF lv_count EQ lv_tcount OR i_down EQ 'S'.
          gs_control_options-no_close = space.
        ENDIF.

        "Birleşik dosya indirirken 1. den sonrakile için AÇMA
        IF i_down EQ 'P' AND lv_count > 1.
          gs_control_options-no_open = 'X'.
        ENDIF.
      ENDIF.




      """""""""""""""""""""""""""YiğitcanÖzdemir""""""""""""""""""""""""""""

      DATA : ls_data TYPE zreco_s_pdf_data."zreco_s_carihesapmutabakat_pdf.

      """""""""""""" Şirket Bilgileri

      DATA: lv_vergid         TYPE string,
            lv_vergino        TYPE string,
            lv_telefon        TYPE string,
            lv_faks           TYPE string,
            lv_mersis         TYPE string,
            lv_ticaret        TYPE string,
            lv_imza           TYPE string,
            lv_unvan          TYPE string,
            lv_adres_1        TYPE string,
            lv_adres_2        TYPE string,
            lv_vd_vkn         TYPE string,
            lv_tsicil         TYPE string,
            lv_ilgili_adi     TYPE string,
            lv_ilgili_telefon TYPE string,
            lv_logo           TYPE string.

* Şirket Unvanı
      lv_unvan = gs_adrs-name.

* Adres
      CONCATENATE gs_adrs-adres1  gs_adrs-adres2 INTO lv_adres_1
      SEPARATED BY space.

      lv_telefon = gs_adrs-telefon.

      lv_faks = gs_adrs-faks.

      lv_vergid  = gs_adrs-vergidairesi.

      lv_vergino = gs_adrs-verginumarasi.

      lv_ticaret = gs_adrs-ticaretsicil.

      lv_mersis  = gs_adrs-mersisno.

      lv_imza    = gs_adrs-imza_logo.

      lv_logo    = gs_adrs-sap_logo.

      " Şehir
      lv_adres_2 = gs_adrs-kent.

      " Semt / Şehir
      IF gs_adrs-semt IS NOT INITIAL.
        CONCATENATE gs_adrs-semt '/' lv_adres_2 INTO lv_adres_2.
      ENDIF.

      " Posta Kodu Semt / Şehir
      IF gs_adrs-pkod IS NOT INITIAL.
        CONCATENATE gs_adrs-pkod lv_adres_2
        INTO lv_adres_2 SEPARATED BY space.
      ENDIF.

      "Telefon
      IF lv_telefon IS NOT INITIAL.
        CONCATENATE 'Tel:' lv_telefon INTO lv_telefon
        SEPARATED BY space.
      ENDIF.

      "Faks
      IF lv_faks IS NOT INITIAL.
        CONCATENATE 'Fax :' lv_faks INTO lv_faks
        SEPARATED BY space.
      ENDIF.

      "Vergi dairesi
      CONCATENATE lv_vergid 'V.D.' lv_vergino INTO lv_vd_vkn
      SEPARATED BY space.


      "Ticaret sicil
      IF lv_ticaret IS NOT INITIAL.
        CONCATENATE 'Ticaret Sicil:' lv_ticaret INTO lv_tsicil
        SEPARATED BY space.
      ENDIF.

      "Mersis No
      IF lv_mersis IS NOT INITIAL.
        CONCATENATE 'Mersis No:' lv_mersis INTO lv_mersis
        SEPARATED BY space.
      ENDIF.

      " İlgili kişi adı
      IF gs_adrs-m_name IS NOT INITIAL.
        lv_ilgili_adi = gs_adrs-m_name.
      ENDIF.

      " İlgili kişi adı ve mail adresi
      IF lv_ilgili_adi IS NOT INITIAL.
        CONCATENATE lv_ilgili_adi '-' gs_adrs-m_email
        INTO lv_ilgili_adi
        SEPARATED BY space.
      ELSEIF gs_adrs-m_email IS NOT INITIAL.
        " İlgili kişi mail adresi
        lv_ilgili_adi = gs_adrs-m_email.
      ENDIF.

      "İlgili kişi telefonu
      IF gs_adrs-m_telefon IS NOT INITIAL.
        lv_ilgili_telefon = gs_adrs-m_telefon.
      ENDIF.

      CLEAR ls_data.


      IF lv_adres_1 IS NOT INITIAL.
        CONCATENATE ls_data-sirket_adres cl_abap_char_utilities=>cr_lf lv_adres_1 INTO ls_data-sirket_adres ."SEPARATED BY space.
      ENDIF.

      IF lv_adres_2 IS NOT INITIAL.
        CONCATENATE ls_data-sirket_adres cl_abap_char_utilities=>cr_lf lv_adres_2 INTO ls_data-sirket_adres ."SEPARATED BY space.
      ENDIF.

      IF lv_telefon IS NOT INITIAL.
        CONCATENATE ls_data-sirket_adres cl_abap_char_utilities=>cr_lf lv_telefon INTO ls_data-sirket_adres ."SEPARATED BY space.
      ENDIF.

      IF lv_faks IS NOT INITIAL.
        CONCATENATE ls_data-sirket_adres cl_abap_char_utilities=>cr_lf lv_faks INTO ls_data-sirket_adres ."SEPARATED BY space.
      ENDIF.

      IF lv_vd_vkn IS NOT INITIAL.
        CONCATENATE ls_data-sirket_adres cl_abap_char_utilities=>cr_lf lv_vd_vkn INTO ls_data-sirket_adres ."SEPARATED BY space.
      ENDIF.

      IF lv_tsicil IS NOT INITIAL.
        CONCATENATE ls_data-sirket_adres cl_abap_char_utilities=>cr_lf lv_tsicil INTO ls_data-sirket_adres ."SEPARATED BY space.
      ENDIF.

      IF lv_mersis IS NOT INITIAL.
        CONCATENATE ls_data-sirket_adres cl_abap_char_utilities=>cr_lf lv_mersis INTO ls_data-sirket_adres ."SEPARATED BY space.
      ENDIF.

      IF lv_ilgili_adi IS NOT INITIAL.
        CONCATENATE ls_data-sirket_adres cl_abap_char_utilities=>cr_lf lv_ilgili_adi INTO ls_data-sirket_adres ."SEPARATED BY space.
      ENDIF.

      IF lv_ilgili_telefon IS NOT INITIAL.
        CONCATENATE ls_data-sirket_adres cl_abap_char_utilities=>cr_lf lv_ilgili_telefon INTO ls_data-sirket_adres ."SEPARATED BY space.
      ENDIF.




      """""""""""""" Şirket Bilgileri
      """""""""""""" Müşteri Bilgileri


      DATA: lv_landx        TYPE string,
            lv_bezei        TYPE string,
            lv_name1        TYPE string,
            lv_cari_adres_1 TYPE string,
            lv_name2        TYPE string,
            lv_name3        TYPE string,
            lv_name4        TYPE string,
            lv_cari_adres_2 TYPE string,
            lv_telf1        TYPE string,
            lv_vd           TYPE string,
            lv_vkn_tckn     TYPE string,
            lv_len          TYPE i.


      lv_name1 = gs_adrc-OrganizationName1.

*    IF gs_flds-name2_use IS INITIAL.
*      IF gs_flds-name2_x IS NOT INITIAL.
      lv_name2 = gs_adrc-OrganizationName2.
*      ENDIF.
*    ELSE.
*      IF gs_flds-name2_x IS NOT INITIAL.
      CONCATENATE lv_cari_adres_1 gs_adrc-OrganizationName2 INTO lv_cari_adres_1
      SEPARATED BY space.

      lv_name3 = gs_adrc-OrganizationName3.
      CONCATENATE lv_cari_adres_1 gs_adrc-OrganizationName3 INTO lv_cari_adres_1
      SEPARATED BY space.

      CONCATENATE lv_cari_adres_1 gs_adrc-street INTO lv_cari_adres_1
      SEPARATED BY space.

      CONCATENATE lv_cari_adres_1 gs_adrc-StreetPrefixName1 INTO lv_cari_adres_1
      SEPARATED BY space.

      CONCATENATE lv_cari_adres_1 gs_adrc-StreetPrefixName2 INTO lv_cari_adres_1
      SEPARATED BY space.

      CONCATENATE lv_cari_adres_1 gs_adrc-DistrictName INTO lv_cari_adres_1
      SEPARATED BY space.

      CONCATENATE lv_cari_adres_1 gs_adrc-building INTO lv_cari_adres_1
      SEPARATED BY space.
*    ENDIF.

      IF gs_flds-roomnumber_x IS NOT INITIAL.
        CONCATENATE lv_cari_adres_1 gs_adrc-roomnumber INTO lv_cari_adres_1
        SEPARATED BY space.
      ENDIF.

      IF gs_flds-floor_x IS NOT INITIAL.
        CONCATENATE lv_cari_adres_1 gs_adrc-floor INTO lv_cari_adres_1
        SEPARATED BY space.
      ENDIF.

      CONCATENATE lv_cari_adres_1 gs_adrc-HouseNumber INTO lv_cari_adres_1
      SEPARATED BY space.

      CONCATENATE lv_cari_adres_1 gs_adrc-HouseNumberSupplementText INTO lv_cari_adres_1
      SEPARATED BY space.


      CONCATENATE lv_cari_adres_2 gs_adrc-CompanyPostalCode INTO lv_cari_adres_2
      SEPARATED BY space.

      CONCATENATE lv_cari_adres_2 gs_adrc-CityName INTO lv_cari_adres_2
      SEPARATED BY space.



      IF gs_account-vd IS NOT INITIAL.
        CONCATENATE gs_account-vd 'V.D.' INTO lv_vd
        SEPARATED BY space.
      ENDIF.

      IF gs_account-vkn_tckn IS NOT INITIAL.

        CLEAR lv_len.

        lv_len = strlen( gs_account-vkn_tckn ).

        IF lv_len EQ 11.
          CONCATENATE 'TCKN:' gs_account-vkn_tckn
          INTO lv_vkn_tckn SEPARATED BY space.
        ELSE.
          CONCATENATE 'VKN:' gs_account-vkn_tckn
          INTO lv_vkn_tckn SEPARATED BY space.
        ENDIF.

      ENDIF.


      SHIFT lv_cari_adres_1 LEFT DELETING LEADING space.
      SHIFT lv_cari_adres_2 LEFT DELETING LEADING space.


      ls_data-cari_adres = lv_name1.

      IF lv_vd IS NOT INITIAL.
        CONCATENATE ls_data-cari_adres cl_abap_char_utilities=>cr_lf lv_vd INTO ls_data-cari_adres ."SEPARATED BY space.
      ENDIF.

      IF lv_vkn_tckn IS NOT INITIAL.
        CONCATENATE ls_data-cari_adres cl_abap_char_utilities=>cr_lf lv_vkn_tckn INTO ls_data-cari_adres ."SEPARATED BY space.
      ENDIF.

      IF lv_telf1 IS NOT INITIAL.
        CONCATENATE ls_data-cari_adres cl_abap_char_utilities=>cr_lf lv_telf1 INTO ls_data-cari_adres ."SEPARATED BY space.
      ENDIF.

      "lv_name3
      IF lv_name3 IS NOT INITIAL.
        CONCATENATE ls_data-cari_adres cl_abap_char_utilities=>cr_lf lv_name3 INTO ls_data-cari_adres ."SEPARATED BY space.
      ENDIF.

      "lv_name4
      IF lv_name4 IS NOT INITIAL.
        CONCATENATE ls_data-cari_adres cl_abap_char_utilities=>cr_lf lv_name4 INTO ls_data-cari_adres ."SEPARATED BY space.
      ENDIF.

      "lv_cari_adres_1
      IF lv_cari_adres_1 IS NOT INITIAL.
        CONCATENATE ls_data-cari_adres cl_abap_char_utilities=>cr_lf lv_cari_adres_1 INTO ls_data-cari_adres ."SEPARATED BY space.
      ENDIF.

      "lv_cari_adres_2
      IF lv_cari_adres_2 IS NOT INITIAL.
        CONCATENATE ls_data-cari_adres cl_abap_char_utilities=>cr_lf lv_cari_adres_2 INTO ls_data-cari_adres ."SEPARATED BY space.
      ENDIF.

      """""""""""""" Müşteri Bilgileri


      gv_first_date = |{ ls_h001-gjahr }{ ls_h001-monat }01|.


      me->rp_last_day_of_months(
       EXPORTING
          day_in            = gv_first_date
        IMPORTING
          last_day_of_month = gv_last_date
*       EXCEPTIONS
*          day_in_no_date    = 1
      ).

      ls_data-duzenleme_tarihi = ls_h001-budat1.
      ls_data-takip            = ls_h001-mnumber.
      ls_data-mutabakat_tarihi = |{ gv_last_date+6(2) }.{ gv_last_date+4(2) }.{ gv_last_date+0(4) }|.
      ls_data-cari_no          = gs_account-hesap_no.

      SELECT SINGLE PersonFullName
      FROM I_BusinessUserBasic
      WHERE UserID = @gs_r000-ernam
      INTO @DATA(lv_cevaplayan).
      ls_data-iletisim         = lv_cevaplayan.

      ls_data-cari_unvan = gs_adrc-OrganizationName1.
      ls_data-sirket_unvan =  lv_unvan.

      ls_data-sirket_kodu =  ls_h001-bukrs.
      ls_data-donemyil =  |{ ls_h001-monat } / { ls_h001-gjahr }|.

*    IF ls_out-nolocal IS NOT INITIAL.
*      DELETE gt_cform_sf WHERE waers NE 'TRY'.
*    ENDIF.

      DATA : lv_toplam TYPE dmbtr.
      DATA : lv_doviz_toplam TYPE dmbtr.
      DATA : lv_borc TYPE dmbtr.
      DATA : lv_doviz_borc TYPE dmbtr.

      LOOP AT gt_cform_sf INTO DATA(ls_form).
        APPEND INITIAL LINE TO ls_data-table1 ASSIGNING FIELD-SYMBOL(<fs_table1>).
        <fs_table1>-hesap_turu   = ls_form-ltext.
        <fs_table1>-doviz_bakiye = ls_form-wrbtr.
        <fs_table1>-pb           = ls_form-waers.
        IF ls_form-dmbtr < 0 .
          <fs_table1>-try_bakiye   = ( -1 ) * ls_form-dmbtr.
          <fs_table1>-borc_alacak  = 'Alacak'.
        ELSEIF  ls_form-dmbtr = 0 .
          <fs_table1>-borc_alacak = ''.
        ELSE.
          <fs_table1>-try_bakiye   = ls_form-dmbtr.
          <fs_table1>-borc_alacak  = 'Borç'.
        ENDIF.



        <fs_table1>-cevap_doviz_bakiye = ls_form-wrbtr_c.
        <fs_table1>-pb2          = ls_form-waers_c.

        IF ls_form-dmbtr_c < 0 .
          <fs_table1>-cevap_try_bakiye = ( -1 ) * ls_form-dmbtr_c.
          <fs_table1>-borc_alacak2 = 'Alacak'.
        ELSEIF  ls_form-dmbtr_c = 0 .
          <fs_table1>-borc_alacak2 = ''.
        ELSE.
          <fs_table1>-cevap_try_bakiye = ls_form-dmbtr_c.
          <fs_table1>-borc_alacak2 = 'Borç'.
        ENDIF.

        IF <fs_table1>-pb EQ 'TRY'.
          lv_toplam = lv_toplam + <fs_table1>-try_bakiye.
        ELSE.
          lv_doviz_toplam = lv_doviz_toplam + <fs_table1>-doviz_bakiye.
        ENDIF.

        IF <fs_table1>-pb2 EQ 'TRY'.
          lv_borc = lv_borc + <fs_table1>-cevap_try_bakiye.
        ELSE.
          lv_doviz_borc = lv_doviz_borc + <fs_table1>-cevap_doviz_bakiye.
        ENDIF.

      ENDLOOP.

      ls_data-toplam = lv_toplam.
      ls_data-doviz_toplam = lv_doviz_toplam.
      ls_data-borc = lv_borc.
      ls_data-doviz_borc = lv_doviz_borc.

      CASE gs_r000-mresult.
        WHEN 'H'.
          ls_data-cevap =  'MUTABIK DEĞİL'.
        WHEN 'E'.
          ls_data-cevap =  'MUTABIK'.
        WHEN 'T'.
          ls_data-cevap =  'KAYIT BULUNMAMAKTA'.
        WHEN 'I'.
          ls_data-cevap =  'İLGİLİ KİŞİ BEN DEĞİLİM'.
        WHEN 'V'.
          ls_data-cevap =  'HÜKÜMSÜZ'.

        WHEN OTHERS.
          ls_data-cevap =  'CEVAP BEKLENİYOR'.
      ENDCASE.
      ls_data-cevaplama_tarihi = gs_r000-erdat.
      ls_data-cevap_not = gs_r000-mtext.

      READ TABLE gt_r001 INTO gs_r001 WHERE bukrs EQ gs_v001-bukrs
                                    AND gsber EQ gs_v001-gsber
                                    AND mnumber EQ gs_v001-mnumber
                                    AND monat EQ gs_v001-monat
                                    AND gjahr EQ gs_v001-gjahr.
      IF sy-subrc EQ 0.

        ls_data-mail = gs_r001-responder_mail.
        ls_data-ad = |{ gs_r001-responder_name } { gs_r001-responder_surname }| .
*        ls_data-surname = gs_r001-responder_surname.
      ENDIF.

      TRY.
          CALL TRANSFORMATION zreco_form_pdf_takip
          SOURCE form = ls_data
          RESULT XML DATA(lv_xml).

        CATCH cx_root INTO DATA(lo_root).
      ENDTRY.

      DATA(lv_base64_data) = cl_web_http_utility=>encode_x_base64( unencoded = lv_xml ).


      TRY.

          DATA lo_ads_util  TYPE REF TO zreco_cl_ads_util.
          CREATE OBJECT lo_ads_util.

          lo_ads_util->call_adobe(
            EXPORTING
              iv_form_name            = 'ZETR_DECO_AF_CARIHESAPMUT'
              iv_template_name        = 'CARIHESAPMUTABAKATI'
              iv_xml                  = lv_base64_data "base64 verisi
              iv_adobe_scenario       = 'ZCLDOBJ_CS_ADS'
              iv_adobe_system         = 'ZCLDOBJ_CSYS_ADS'
              iv_adobe_service_id     = 'ZCLDOBJ_OS_ADS_REST'
            IMPORTING
              ev_pdf                  = DATA(lv_pdf)
              ev_response_code        = DATA(lv_res_c)
              ev_response_text        = DATA(lv_res_t)
          ).
        CATCH cx_http_dest_provider_error.
          "handle exception
      ENDTRY.

      IF lv_pdf IS NOT INITIAL.
        ev_pdf = lv_pdf.
      ENDIF.


    ENDLOOP.


  ENDMETHOD.