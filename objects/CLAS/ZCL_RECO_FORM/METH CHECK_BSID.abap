  METHOD check_bsid.
    SELECT SINGLE *
       FROM zetr_reco_ddl_bsid
           WHERE companycode IN @s_bukrs  AND
                 customer EQ @iv_kunnr AND
                     ( postingdate LE @gv_last_date AND postingdate GE @iv_budat ) AND
                     specialglcode IN @r_umskz_m
                     INTO @DATA(ls_bsid) .

    cv_closing_rc = sy-subrc.

  ENDMETHOD.