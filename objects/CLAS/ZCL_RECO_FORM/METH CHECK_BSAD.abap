  METHOD check_bsad.

    SELECT SINGLE *
    FROM i_operationalacctgdocitem
    INNER JOIN i_oplacctgdocitemclrghist
    ON i_operationalacctgdocitem~companycode = i_oplacctgdocitemclrghist~clearedcompanycode
    AND i_operationalacctgdocitem~accountingdocument = i_oplacctgdocitemclrghist~clearedaccountingdocument
    AND i_operationalacctgdocitem~fiscalyear = i_oplacctgdocitemclrghist~clearedfiscalyear
    AND i_operationalacctgdocitem~accountingdocumentitem = i_oplacctgdocitemclrghist~clearedaccountingdocumentitem
        WHERE i_operationalacctgdocitem~companycode IN @s_bukrs  AND
              i_operationalacctgdocitem~customer EQ @iv_kunnr AND
                  ( i_operationalacctgdocitem~postingdate LE @gv_last_date AND i_operationalacctgdocitem~postingdate GE @iv_budat ) AND
                  i_operationalacctgdocitem~specialglcode IN @r_umskz_m AND
                  i_oplacctgdocitemclrghist~financialaccounttype = 'D'
                  INTO @DATA(ls_bsad) .

    cv_closing_rc = sy-subrc.

  ENDMETHOD.