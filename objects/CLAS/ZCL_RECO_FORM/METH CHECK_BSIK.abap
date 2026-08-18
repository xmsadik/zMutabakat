  METHOD check_bsik.
*    DATA ls_bsik TYPE bsik_view.
*
    SELECT SINGLE *
         FROM zetr_reco_ddl_bsik
             WHERE companycode IN @s_bukrs  AND
                   supplier EQ @iv_lifnr AND
                       ( postingdate LE @gv_last_date AND postingdate GE @iv_budat ) AND
                       specialglcode IN @r_umskz_m
                       INTO @DATA(ls_bsik) .
*
    cv_closing_rc = sy-subrc.

  ENDMETHOD.