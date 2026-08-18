  METHOD zreco_to_mail_adrs.

    TYPES: BEGIN OF ty_kna1,
             kunnr TYPE kunnr,
             adrnr TYPE zreco_adrnr,
           END OF ty_kna1.

    TYPES: BEGIN OF ty_lfa1,
             lifnr TYPE lifnr,
             adrnr TYPE zreco_adrnr,
           END OF ty_lfa1.

    TYPES: BEGIN OF ty_adr6,
             smtp_addr TYPE zreco_ad_smtpadr,
           END OF ty_adr6.

    TYPES: BEGIN OF ty_knvk,
             prsnr TYPE ad_persnum,
           END OF ty_knvk.


    DATA : lt_e003 TYPE SORTED TABLE OF zreco_eate
                WITH NON-UNIQUE KEY smtp_addr.


    DATA : lt_mast TYPE SORTED TABLE OF zreco_mast
                WITH NON-UNIQUE KEY  kunnr lifnr.

    DATA : r_adrnr TYPE RANGE OF kunnr,
           r_mtype TYPE RANGE OF zreco_hdr-mtype.

    DATA : ls_adrnr LIKE LINE OF r_adrnr,
           ls_mtype LIKE LINE OF r_mtype.


    DATA : lt_kna1 TYPE TABLE OF ty_kna1,
           lt_lfa1 TYPE TABLE OF ty_lfa1,
           lt_adr6 TYPE TABLE OF ty_adr6,
           lt_knvk TYPE TABLE OF ty_knvk.

    DATA : ls_kna1 TYPE  ty_kna1,
           ls_lfa1 TYPE  ty_lfa1,
           ls_adr6 TYPE  ty_adr6,
           ls_knvk TYPE  ty_knvk.

    DATA : ls_receivers TYPE zreco_somlreci1.


    ls_mtype-sign = 'I'.
    ls_mtype-option = 'EQ'.
    ls_mtype-low = i_mtype.
    APPEND ls_mtype TO r_mtype .

    IF i_kunnr IS NOT INITIAL.                    "YiğitcanÖ. 27092023
      i_kunnr = |{ i_kunnr ALPHA = IN }|.
    ENDIF.

    IF i_lifnr IS NOT INITIAL.                    "YiğitcanÖ. 27092023
      i_lifnr = |{ i_lifnr ALPHA = IN }|.
    ENDIF.



    IF i_kunnr IS NOT INITIAL.
      IF i_all IS NOT INITIAL.
        SELECT SINGLE COUNT(*)
                 FROM zreco_etax
                WHERE bukrs EQ @i_bukrs
                  AND stcd2 EQ @i_stcd1.
        IF sy-subrc NE 0.
          SELECT *
            FROM zreco_taxm
           WHERE vkn_tckn EQ @i_stcd1
            INTO CORRESPONDING FIELDS OF TABLE @lt_kna1.
        ENDIF.
      ENDIF.

      SELECT customer AS kunnr,
             AddressID AS adrnr
            FROM i_customer
           WHERE customer EQ @i_kunnr
            APPENDING TABLE @lt_kna1.

      DELETE lt_kna1 WHERE kunnr IS INITIAL.

      SORT lt_kna1 BY adrnr.

      DELETE ADJACENT DUPLICATES FROM lt_kna1 COMPARING adrnr.


      SELECT SINGLE COUNT(*)
               FROM zreco_adrs
              WHERE bukrs EQ @i_bukrs
                AND master_data EQ @space.

      IF sy-subrc EQ 0 .

        IF lt_kna1[] IS NOT INITIAL.  "YiğitcanÖ. 26092023.
          SELECT *
            FROM zreco_mast
             FOR ALL ENTRIES IN @lt_kna1
           WHERE bukrs EQ @i_bukrs
             AND kunnr EQ @lt_kna1-kunnr
             AND mtype IN @r_mtype
               INTO TABLE @lt_mast.
        ENDIF.

        IF lt_mast[] IS NOT INITIAL.
          LOOP AT lt_mast INTO DATA(ls_mast).
            READ TABLE lt_e003 TRANSPORTING NO FIELDS WITH KEY smtp_addr = ls_mast-smtp_addr.
            CHECK sy-subrc NE 0.
            IF e_mail IS INITIAL.
              e_mail = ls_mast-smtp_addr.
            ENDIF.

            ls_receivers-receiver = ls_mast-smtp_addr.
            ls_receivers-rec_type = 'U'.
            APPEND ls_receivers TO t_receivers .
            CLEAR  ls_receivers .
          ENDLOOP.
        ELSE.
**adrc
          LOOP AT lt_kna1 INTO ls_kna1.
            SELECT SINGLE COUNT(*)
                     FROM i_customercompany AS knb1
                    WHERE companycode EQ @i_bukrs
                      AND customer EQ @ls_kna1-kunnr.
            IF sy-subrc NE 0.
*            DELETE lt_kna1.
              DELETE lt_kna1 WHERE kunnr EQ ls_kna1-kunnr.
              CONTINUE.
            ENDIF.
            ls_adrnr-sign = 'I'.
            ls_adrnr-option = 'EQ'.
            ls_adrnr-low = ls_kna1-adrnr.
            APPEND ls_adrnr TO r_adrnr.
          ENDLOOP.
          IF lt_kna1[] IS NOT INITIAL.
            SELECT EmailAddress AS smtp_addr
              FROM  I_AddrCurDefaultEmailAddress WITH PRIVILEGED ACCESS"I_AddressEmailAddress_2
               AS adr6
               FOR ALL ENTRIES IN @lt_kna1
             WHERE AddressID EQ @lt_kna1-adrnr
               AND AddressPersonID EQ ''
             INTO TABLE @lt_adr6.
          ENDIF.
        ENDIF.

        LOOP AT lt_adr6 INTO ls_adr6 WHERE smtp_addr IS NOT INITIAL.
          IF e_mail IS INITIAL.
            e_mail = ls_adr6-smtp_addr.
          ENDIF.

          ls_receivers-receiver = ls_adr6-smtp_addr.
          ls_receivers-rec_type = 'U'.
          APPEND ls_receivers TO t_receivers .
          CLEAR  ls_receivers .
        ENDLOOP.


      ELSE.

*İlgili kişiden verileri çek
        IF i_abtnr IS NOT INITIAL.

          IF lt_kna1[] IS NOT INITIAL.
            LOOP AT lt_kna1 INTO DATA(s_kna1).
              SELECT SINGLE COUNT(*)
                       FROM i_customercompany
                      WHERE companycode EQ @i_bukrs
                        AND customer EQ @s_kna1-kunnr.
              IF sy-subrc NE 0.
*              DELETE lt_kna1.
                DELETE lt_kna1 WHERE kunnr EQ s_kna1-kunnr.
                CONTINUE.
              ENDIF.
              ls_adrnr-sign = 'I'.
              ls_adrnr-option = 'EQ'.
              ls_adrnr-low = s_kna1-adrnr.
              APPEND ls_adrnr TO r_adrnr.
            ENDLOOP.

            CHECK lt_kna1[] IS NOT INITIAL.

            SELECT PersonNumber AS prsnr
              FROM i_contactperson AS knvk
               FOR ALL ENTRIES IN @lt_kna1
             WHERE customer EQ @lt_kna1-kunnr
               AND ContactPersonDepartment EQ @i_abtnr
               AND ContactPersonFunction EQ @i_pafkt
              INTO TABLE @lt_knvk.
            IF sy-subrc NE 0.

              IF i_no_general IS INITIAL.
                IF lt_kna1[] IS NOT INITIAL. "Aynı VKN'ye sahip olanlar

                  IF i_remark IS NOT INITIAL.

                  ELSE.
                    SELECT EmailAddress AS smtp_addr
                      FROM I_AddrCurDefaultEmailAddress WITH PRIVILEGED ACCESS"I_AddressEmailAddress_2
                      AS adr6
                       FOR ALL ENTRIES IN @lt_kna1
                     WHERE AddressID EQ @lt_kna1-adrnr
                       AND AddressPersonID EQ ''
                      INTO TABLE @lt_adr6.
                  ENDIF.

                  LOOP AT lt_adr6 INTO ls_adr6 WHERE smtp_addr IS NOT INITIAL.

                    IF e_mail IS INITIAL.
                      e_mail = ls_adr6-smtp_addr.
                    ENDIF.

                    ls_receivers-receiver = ls_adr6-smtp_addr.
                    ls_receivers-rec_type = 'U'.
                    APPEND ls_receivers TO t_receivers .
                    CLEAR  ls_receivers .

                  ENDLOOP.

                ELSE.

                  IF i_remark IS NOT INITIAL.
                    IF r_adrnr[] IS NOT INITIAL.
                    ENDIF.
                  ELSE.
                    IF r_adrnr[] IS NOT INITIAL.
                      SELECT SINGLE EmailAddress AS smtp_addr
                               FROM I_AddrCurDefaultEmailAddress WITH PRIVILEGED ACCESS"I_AddressEmailAddress_2
                               AS adr6
                              WHERE AddressID IN @r_adrnr
                                AND AddressPersonID EQ ''

                               INTO @e_mail.
                    ENDIF.
                  ENDIF.

                  IF e_mail IS NOT INITIAL.
                    ls_receivers-receiver = e_mail.
                    ls_receivers-rec_type = 'U'.
                    APPEND ls_receivers TO t_receivers .
                    CLEAR  ls_receivers .
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.

          ELSE.
            SELECT PersonNumber AS prsnr
              FROM i_contactperson AS knvk
             WHERE customer EQ @i_kunnr
               AND ContactPersonDepartment EQ @i_abtnr
               AND ContactPersonFunction EQ @i_pafkt

              INTO TABLE @lt_knvk.
          ENDIF.

          IF lt_knvk[] IS NOT INITIAL.
            IF r_adrnr[] IS NOT INITIAL.
              SELECT  EmailAddress AS smtp_addr
               FROM I_AddrCurDefaultEmailAddress WITH PRIVILEGED ACCESS    "I_AddressEmailAddress_2
               AS adr6
                FOR ALL ENTRIES IN @lt_knvk
                WHERE AddressID IN @r_adrnr
                AND AddressPersonID   EQ @lt_knvk-prsnr
                INTO TABLE @lt_adr6.
            ENDIF.

            LOOP AT lt_adr6 INTO ls_adr6 WHERE smtp_addr IS NOT INITIAL.
              IF e_mail IS INITIAL.
                e_mail = ls_adr6-smtp_addr.
              ENDIF.

              ls_receivers-receiver = ls_adr6-smtp_addr.
              ls_receivers-rec_type = 'U'.
              APPEND ls_receivers TO t_receivers .
              CLEAR  ls_receivers .

              i_no_general = 'X'.

            ENDLOOP.
          ENDIF.

        ELSE.
*endif.
* İlgili kişi yoksa genel verilerden çek
          LOOP AT lt_kna1 INTO ls_kna1.
            SELECT SINGLE COUNT(*)
                     FROM i_customercompany AS knb1
                    WHERE companycode EQ @i_bukrs
                      AND customer EQ @ls_kna1-kunnr.
            IF sy-subrc NE 0.
*            DELETE lt_kna1.
              DELETE lt_kna1 WHERE kunnr EQ ls_kna1-kunnr.
              CONTINUE.
            ENDIF.
            ls_adrnr-sign = 'I'.
            ls_adrnr-option = 'EQ'.
            ls_adrnr-low = ls_kna1-adrnr.
            APPEND ls_adrnr TO r_adrnr.
          ENDLOOP.

          IF i_no_general IS INITIAL.
            IF lt_kna1[] IS NOT INITIAL. "Aynı VKN'ye sahip olanlar

              IF i_remark IS NOT INITIAL.
              ELSE.
                SELECT EmailAddress AS smtp_addr
                  FROM I_AddrCurDefaultEmailAddress WITH PRIVILEGED ACCESS"I_AddressEmailAddress_2
                   FOR ALL ENTRIES IN @lt_kna1
                 WHERE AddressID EQ @lt_kna1-adrnr
                   AND AddressPersonID   EQ ''
                  INTO TABLE @lt_adr6.
              ENDIF.

              LOOP AT lt_adr6 INTO ls_adr6 WHERE smtp_addr IS NOT INITIAL.

                IF e_mail IS INITIAL.
                  e_mail = ls_adr6-smtp_addr.
                ENDIF.

                ls_receivers-receiver = ls_adr6-smtp_addr.
                ls_receivers-rec_type = 'U'.
                APPEND ls_receivers TO t_receivers .
                CLEAR  ls_receivers .
              ENDLOOP.
            ELSE.

              IF i_remark IS NOT INITIAL.
                IF r_adrnr IS NOT INITIAL.
                ENDIF.
              ELSE.
                IF r_adrnr[] IS NOT INITIAL.
                  SELECT SINGLE EmailAddress AS smtp_addr FROM  I_AddrCurDefaultEmailAddress WITH PRIVILEGED ACCESS"I_AddressEmailAddress_2
                  AS adr6
                  WHERE AddressID IN @r_adrnr
                   AND AddressPersonID EQ ''
                      INTO @e_mail.
                ENDIF.
              ENDIF.

              IF e_mail IS NOT INITIAL.
                ls_receivers-receiver = e_mail.
                ls_receivers-rec_type = 'U'.
                APPEND ls_receivers TO t_receivers .
                CLEAR  ls_receivers .
              ENDIF.

            ENDIF.
            IF e_mail IS INITIAL AND i_ucomm NE 'FAX'.
              IF r_adrnr[] IS NOT INITIAL.
                SELECT SINGLE EmailAddress AS smtp_addr FROM I_AddrCurDefaultEmailAddress WITH PRIVILEGED ACCESS" I_AddressEmailAddress_2
                AS adr6
                WHERE AddressID IN @r_adrnr
                 AND AddressPersonID EQ ''
                    INTO @e_mail.
              ENDIF.

              IF e_mail IS NOT INITIAL.

                ls_receivers-receiver = ls_adr6-smtp_addr.
                ls_receivers-rec_type = 'U'.
                APPEND ls_receivers TO t_receivers .
                CLEAR  ls_receivers .
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      SORT t_receivers BY receiver.

      DELETE ADJACENT DUPLICATES FROM t_receivers COMPARING receiver.

    ENDIF.


    IF i_lifnr IS NOT INITIAL.

      CLEAR r_adrnr.

      IF i_all IS NOT INITIAL.
        SELECT SINGLE COUNT(*)
                 FROM zreco_etax
                WHERE bukrs EQ @i_bukrs
                  AND stcd2 EQ @i_stcd1.
        IF sy-subrc NE 0.
          SELECT *
            FROM zreco_taxm
           WHERE vkn_tckn EQ @i_stcd1
           INTO CORRESPONDING FIELDS OF TABLE @lt_lfa1.
        ENDIF.
      ENDIF.

      SELECT supplier AS lifnr,
             AddressID AS adrnr
        FROM i_supplier AS lfa1
       WHERE supplier EQ @i_lifnr
        APPENDING TABLE @lt_lfa1.

      DELETE lt_lfa1 WHERE lifnr IS INITIAL.

      SORT lt_lfa1 BY adrnr.

      DELETE ADJACENT DUPLICATES FROM lt_lfa1 COMPARING adrnr.

      SELECT SINGLE COUNT(*)
               FROM zreco_adrs
              WHERE bukrs EQ @i_bukrs
                AND master_data EQ @space.
      IF sy-subrc EQ 0.
        IF lt_lfa1[] IS NOT INITIAL.
          SELECT *
            FROM zreco_mast
             FOR ALL ENTRIES IN @lt_lfa1
           WHERE bukrs EQ @i_bukrs
             AND lifnr EQ @lt_lfa1-lifnr
             AND mtype IN @r_mtype
            INTO TABLE @lt_mast.
        ENDIF.
        IF lt_mast[] IS NOT INITIAL.
          LOOP AT lt_mast INTO ls_mast.

            READ TABLE lt_e003 TRANSPORTING NO FIELDS WITH KEY smtp_addr = ls_mast-smtp_addr.

            CHECK sy-subrc NE 0.

            IF e_mail IS INITIAL.
              e_mail = ls_mast-smtp_addr.
            ENDIF.

            ls_receivers-receiver = ls_mast-smtp_addr.
            ls_receivers-rec_type = 'U'.
            APPEND ls_receivers TO t_receivers .
            CLEAR  ls_receivers .

          ENDLOOP.
        ELSE.
**adrc
          LOOP AT lt_lfa1 INTO ls_lfa1.
            SELECT SINGLE COUNT(*)
                     FROM i_suppliercompany
                    WHERE companycode EQ @i_bukrs
                      AND supplier EQ @ls_lfa1-lifnr.
            IF sy-subrc NE 0.
              DELETE lt_lfa1 WHERE lifnr = ls_lfa1-lifnr.
              CONTINUE.
            ENDIF.
            ls_adrnr-sign = 'I'.
            ls_adrnr-option = 'EQ'.
            ls_adrnr-low = ls_lfa1-adrnr.
            APPEND ls_adrnr TO r_adrnr.
          ENDLOOP.

          IF lt_lfa1[] IS NOT INITIAL.


            SELECT  EmailAddress AS smtp_addr
            FROM I_AddrCurDefaultEmailAddress WITH PRIVILEGED ACCESS"I_AddressEmailAddress_2
            AS adr6
            FOR ALL ENTRIES IN @lt_lfa1
            WHERE AddressID EQ @lt_lfa1-adrnr
            AND AddressPersonID EQ ''
            INTO TABLE @lt_adr6.
          ENDIF.

          LOOP AT lt_adr6 INTO ls_adr6 WHERE smtp_addr IS NOT INITIAL.

            IF e_mail IS INITIAL.
              e_mail = ls_adr6-smtp_addr.
            ENDIF.

            ls_receivers-receiver = ls_adr6-smtp_addr.
            ls_receivers-rec_type = 'U'.
            APPEND ls_receivers TO t_receivers .
            CLEAR  ls_receivers .

          ENDLOOP.
        ENDIF.
      ELSE.

*İlgili kişiden verileri çek
        IF i_abtnr IS NOT INITIAL.
          IF lt_lfa1[] IS NOT INITIAL.

            LOOP AT lt_lfa1 INTO ls_lfa1.
              SELECT SINGLE COUNT(*)
                       FROM i_suppliercompany
                      WHERE companycode EQ @i_bukrs
                       AND supplier EQ @ls_lfa1-lifnr.
              IF sy-subrc NE 0.
                DELETE lt_lfa1 WHERE lifnr = ls_lfa1-lifnr.
                CONTINUE.
              ENDIF.
              ls_adrnr-sign = 'I'.
              ls_adrnr-option = 'EQ'.
              ls_adrnr-low = ls_lfa1-adrnr.
              APPEND ls_adrnr TO r_adrnr.
            ENDLOOP.

            CHECK lt_lfa1[] IS NOT INITIAL.

            SELECT personnumber AS prsnr
              FROM i_contactperson
               FOR ALL ENTRIES IN @lt_lfa1
             WHERE supplier EQ @lt_lfa1-lifnr
               AND ContactPersonDepartment EQ @i_abtnr
               AND ContactPersonFunction EQ @i_pafkt
              INTO TABLE @lt_knvk.

            IF sy-subrc NE 0.
              IF i_no_general IS INITIAL.
                IF lt_lfa1[] IS NOT INITIAL. "Aynı VKN'ye sahip olanlar

                  IF i_remark IS NOT INITIAL.

                  ELSE.
                    SELECT EmailAddress AS smtp_addr
                      FROM I_AddrCurDefaultEmailAddress WITH PRIVILEGED ACCESS"I_AddressEmailAddress_2
                      AS adr6
                       FOR ALL ENTRIES IN @lt_lfa1
                     WHERE AddressID EQ @lt_lfa1-adrnr
                       AND AddressPersonID   EQ ''
                      INTO TABLE @lt_adr6.
                  ENDIF.

                  LOOP AT lt_adr6 INTO ls_adr6 WHERE smtp_addr IS NOT INITIAL.

                    IF e_mail IS INITIAL.
                      e_mail = ls_adr6-smtp_addr.
                    ENDIF.

                    ls_receivers-receiver = ls_adr6-smtp_addr.
                    ls_receivers-rec_type = 'U'.
                    APPEND ls_receivers TO t_receivers .
                    CLEAR  ls_receivers .
                  ENDLOOP.
                ELSE.
                  IF i_remark IS NOT INITIAL.
                    IF r_adrnr[] IS NOT INITIAL.

                    ENDIF.
                  ELSE.
                    IF r_adrnr[] IS NOT INITIAL.
                      SELECT SINGLE EmailAddress AS smtp_addr
                               FROM I_AddrCurDefaultEmailAddress WITH PRIVILEGED ACCESS"I_AddressEmailAddress_2
                               AS adr6

                              WHERE AddressID IN @r_adrnr
                                AND AddressPersonID EQ ''
                                 INTO @e_mail.
                    ENDIF.
                  ENDIF.

                  IF e_mail IS NOT INITIAL.
                    ls_receivers-receiver = e_mail.
                    ls_receivers-rec_type = 'U'.
                    APPEND ls_receivers TO t_receivers .
                    CLEAR  ls_receivers .
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ELSE.


            SELECT personnumber AS prsnr
              FROM i_contactperson
             WHERE supplier EQ @i_lifnr
               AND ContactPersonDepartment EQ @i_abtnr
               AND ContactPersonFunction EQ @i_pafkt
              INTO TABLE @lt_knvk.

          ENDIF.

          IF lt_knvk[] IS NOT INITIAL.

            IF r_adrnr[] IS NOT INITIAL.

              SELECT  EmailAddress AS smtp_addr
            FROM I_AddrCurDefaultEmailAddress WITH PRIVILEGED ACCESS
                      FOR ALL ENTRIES IN @lt_knvk
                         WHERE AddressID IN @r_adrnr
                           AND AddressPersonID   EQ @lt_knvk-prsnr
                           INTO TABLE @lt_adr6.

            ENDIF.

            LOOP AT lt_adr6 INTO ls_adr6 WHERE smtp_addr IS NOT INITIAL.

              IF e_mail IS INITIAL.
                e_mail = ls_adr6-smtp_addr.
              ENDIF.

              ls_receivers-receiver = ls_adr6-smtp_addr.
              ls_receivers-rec_type = 'U'.
              APPEND ls_receivers TO  t_receivers .
              CLEAR  t_receivers .

              i_no_general = 'X'.

            ENDLOOP.
          ENDIF.
        ELSE.

          LOOP AT lt_lfa1 INTO ls_lfa1.
            SELECT SINGLE COUNT(*)
                     FROM i_suppliercompany AS lfb1
                    WHERE companycode EQ @i_bukrs
                      AND supplier EQ @ls_lfa1-lifnr.
            IF sy-subrc NE 0.
              DELETE lt_lfa1 WHERE lifnr = ls_lfa1-lifnr.
              CONTINUE.
            ENDIF.
            ls_adrnr-sign = 'I'.
            ls_adrnr-option = 'EQ'.
            ls_adrnr-low = ls_lfa1-adrnr.
            APPEND ls_adrnr TO r_adrnr.
          ENDLOOP.

* İlgili kişi yoksa genel verilerden çek
          IF i_no_general IS INITIAL.

            IF lt_lfa1[] IS NOT INITIAL. "Aynı VKN'ye sahip olanlar

              IF i_remark IS NOT INITIAL.
              ELSE.

                SELECT  EmailAddress AS smtp_addr
              FROM I_AddrCurDefaultEmailAddress WITH PRIVILEGED ACCESS
                        FOR ALL ENTRIES IN @lt_lfa1
                             WHERE AddressID EQ @lt_lfa1-adrnr
                               AND AddressPersonID   EQ ''
                              INTO TABLE @lt_adr6.
              ENDIF.

              LOOP AT lt_adr6 INTO ls_adr6 WHERE smtp_addr IS NOT INITIAL.
                IF e_mail IS INITIAL.
                  e_mail = ls_adr6-smtp_addr.
                ENDIF.

                ls_receivers-receiver = ls_adr6-smtp_addr.
                ls_receivers-rec_type = 'U'.
                APPEND ls_receivers TO t_receivers .
                CLEAR  ls_receivers .
              ENDLOOP.

            ELSE.

              IF i_remark IS NOT INITIAL.
                IF r_adrnr[] IS NOT INITIAL.
                ENDIF.
              ELSE.
                IF r_adrnr[] IS NOT INITIAL.

                  SELECT SINGLE EmailAddress AS smtp_addr
            FROM I_AddrCurDefaultEmailAddress WITH PRIVILEGED ACCESS AS adr6
           WHERE AddressID IN @r_adrnr
             AND AddressPersonID EQ ''
              INTO @e_mail.
                ENDIF.
              ENDIF.

              IF e_mail IS NOT INITIAL.
                ls_receivers-receiver = e_mail.
                ls_receivers-rec_type = 'U'.
                APPEND ls_receivers TO t_receivers .
                CLEAR  ls_receivers .
              ENDIF.
            ENDIF.
            IF e_mail IS INITIAL.

              IF i_remark IS NOT INITIAL.
                IF r_adrnr[] IS NOT INITIAL.

                ENDIF.
              ELSE.
                IF r_adrnr[] IS NOT INITIAL.
                  SELECT SINGLE EmailAddress AS smtp_addr
                                  FROM I_AddrCurDefaultEmailAddress WITH PRIVILEGED ACCESS AS adr6
                                 WHERE AddressID IN @r_adrnr
                                   AND AddressPersonID EQ ''
                          INTO @e_mail.
                ENDIF.
              ENDIF.

              IF e_mail IS NOT INITIAL.
                ls_receivers-receiver = e_mail.
                ls_receivers-rec_type = 'U'.
                APPEND ls_receivers TO t_receivers .
                CLEAR  ls_receivers .
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      SORT t_receivers BY receiver.

      DELETE ADJACENT DUPLICATES FROM t_receivers COMPARING receiver.

    ENDIF.

    DATA lt_receivers TYPE STANDARD TABLE OF zreco_somlreci1.


    IF lt_receivers[] IS NOT INITIAL.
      APPEND LINES OF lt_receivers TO t_receivers.
    ENDIF.

    LOOP AT t_receivers INTO ls_receivers.
      READ TABLE lt_e003 TRANSPORTING NO FIELDS  WITH KEY smtp_addr = ls_receivers-receiver.
      IF sy-subrc EQ 0.
        DELETE t_receivers .
      ENDIF.
    ENDLOOP.

    IF e_mail IS NOT INITIAL.
      READ TABLE lt_e003 TRANSPORTING NO FIELDS WITH KEY smtp_addr = e_mail.
      IF sy-subrc EQ 0.
        CLEAR e_mail.
      ENDIF.
    ENDIF.




  ENDMETHOD.