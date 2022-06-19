--TODO: discutno 高达12个
--TODO: 检查非0初始化 合理？

declare

  type mdownamounts_t IS VARRAY(3) OF sale_cfg_discountsection.downamount%type;
  type mupamounts_t IS VARRAY(3) OF sale_cfg_discountsection.upamount%type;
  type mfeerates_t IS VARRAY(3) OF CFG_FEEDETAIL.FEERATE%type;
  type mratevalues_t IS VARRAY(3) OF sale_cfg_discountsection.ratevalue%type;
  type mdiscountnos_t IS VARRAY(12) OF sale_cfg_discountsection.discountno%type;
  
  mdownamount mdownamounts_t := mdownamounts_t();
  mupamount mupamounts_t := mupamounts_t();
  mfeerate mfeerates_t := mfeerates_t();
  mratevalue mratevalues_t := mratevalues_t(); --0.006 and 0.0006
  mdiscountno mdiscountnos_t := mdiscountnos_t();
  
  v_rownum int := 0;
  i int := 0;
  mupdate_sql VARCHAR2(9999) := '';
  
  /* --verify
 select t.tano,a.fundcode,a.businesscode,a.downamount, a.upamount, t.feerate,a.ratevalue
          from (select b.fundcode, b.businesscode,a.downamount,a.upamount,a.ratevalue
                  from sale_cfg_discountsection a
                  left join sale_cfg_discount_paycenter b on a.discountno = b.discountno
                 where b.operway = '2'and b.paycenterid = '0206') a
         inner join (select b.fundcode,b.tano,b.businesscode,a.downamount,a.upamount,max(a.feerate) feerate
                       from CFG_FEEDETAIL a
                      INNER JOIN CFG_FEEZONE b on a.feeno = b.feeno
                      where a.feeno in (select feeno from CFG_FEEZONE  where FEEPOLICY = 3  and feetype = 2)
                        and a.feepolicy = 1
                      group by b.fundcode,b.tano,b.businesscode, a.downamount, a.upamount) t
            on a.fundcode = t.fundcode and a.businesscode = t.businesscode and a.downamount = t.downamount  and a.upamount = t.upamount
            where a.fundcode='121001'
            order by t.tano,a.fundcode,a.businesscode,a.downamount, a.upamount
*/
  /* --verify
select b.operway,b.paycenterid,b.businesscode,b.fundcode,a.downamount,a.upamount,a.valuetype,a.ratevalue,a.discountno
                  from sale_cfg_discountsection a
                  left join sale_cfg_discount_paycenter b on a.discountno = b.discountno
                 where b.fundcode='007266' and b.paycenterid = '0206' and b.businesscode in ('22', '39'); 
*/
  mmfundcode VARCHAR2(6) := '000329';  -- fundcode
  
  cursor cemp(mfundcode char) is select t.tano,a.fundcode,a.businesscode,a.downamount, a.upamount, t.feerate,a.ratevalue from (select b.fundcode, b.businesscode,a.downamount,a.upamount,a.ratevalue from sale_cfg_discountsection a left join sale_cfg_discount_paycenter b on a.discountno = b.discountno where b.operway = '2'and b.paycenterid = '0206') a inner join (select b.fundcode,b.tano,b.businesscode,a.downamount,a.upamount,max(a.feerate) feerate from CFG_FEEDETAIL a INNER JOIN CFG_FEEZONE b on a.feeno = b.feeno where a.feeno in (select feeno from CFG_FEEZONE  where FEEPOLICY = 3  and feetype = 2) and a.feepolicy = 1 group by b.fundcode,b.tano,b.businesscode, a.downamount, a.upamount) t  on a.fundcode = t.fundcode and a.businesscode = t.businesscode and a.downamount = t.downamount  and a.upamount = t.upamount where a.fundcode = mfundcode  /*'008887'*/ order by t.tano,a.fundcode,a.businesscode,a.downamount, a.upamount;
  --cursor cemp(mfundcode char) is select * from fund_nav where fundcode = mfundcode;
  cursor cdiscountno(mfundcode char) is select distinct discountno from ( select b.operway,b.paycenterid,b.businesscode,b.fundcode,a.downamount,a.upamount,a.valuetype,a.ratevalue,a.discountno from sale_cfg_discountsection a left join sale_cfg_discount_paycenter b on a.discountno = b.discountno where b.fundcode = mfundcode /*'008887'*/ and b.paycenterid = '0206' and b.businesscode in ('22', '39') ); 
  
begin   
     
  --open cemp('008887');
  for c in cemp(mmfundcode) loop 
    i := i + 1;
    
    mdownamount.EXTEND;
    mupamount.EXTEND;
    mfeerate.EXTEND;
    mratevalue.EXTEND;
    
    mdownamount(i) := c.downamount;
    mupamount(i) := c.upamount;
    mfeerate(i) := c.feerate;
    mratevalue(i) := c.ratevalue;
    
    --dbms_output.put_line('mdownamount= ' || mdownamount(i) || ' upamount : ' || mupamount(i) || ' feerate : ' || mfeerate(i) || ' mratrvalue :  ' || mratevalue(i));
  end loop; 
  
  i := 0;
  --get discountno /begin
  for c in cdiscountno(mmfundcode) loop 
    i := i + 1;
    mdiscountno.EXTEND;
    mdiscountno(i) := c.discountno;
    --dbms_output.put_line('mdiscountno = ' || mdiscountno(i));
  end loop; 
  --get discountno /end
  
  i := 0;
  for i in mdownamount.first..mdownamount.last loop  --mupamount?
    dbms_output.put_line('update++ : ');
    mupdate_sql := 'update sale_cfg_discountsection set ratevalue = ' || mfeerate(i) || ' * 0.1 where discountno in (';
    
    --set discountno
    for j in mdiscountno.first..mdiscountno.last loop
        --dbms_output.put_line(mdiscountno(j));
        mupdate_sql := mupdate_sql || mdiscountno(j) || ',';
    end loop;
    
    mupdate_sql := trim(trailing ',' from mupdate_sql) || ') ';
    mupdate_sql := mupdate_sql || 'and downamount = ' || mdownamount(i) || ' and upamount = ' || mupamount(i)/* || ';'*/;
    dbms_output.put_line(mupdate_sql);
    execute immediate mupdate_sql;
    --update sale_cfg_discountsection set ratevalue = mfeerate(i) * 0.1 where discountno in mdiscountno /*('47437', '47439', '47438', '47440')*/ /*and ratevalue = mratevalue(i)*/ and downamount = mdownamount(i) and upamount = mupamount(i);
    v_rownum := SQL%ROWCOUNT;
    dbms_output.put_line('update-- : ' || v_rownum  || ' Lines updated.');
    v_rownum := 0;
  end loop;

end;




