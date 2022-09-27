select `c_last_name`, `c_first_name`, `c_salutation`, `c_preferred_cust_flag`, `ss_ticket_number`, `cnt`
from (select `ss_ticket_number`, `ss_customer_sk`, count(*) as `cnt`
from `store_sales`
where `store_sales`.`ss_sold_date_sk` = `date_dim`.`d_date_sk` and `store_sales`.`ss_store_sk` = `store`.`s_store_sk` and `store_sales`.`ss_hdemo_sk` = `household_demographics`.`hd_demo_sk` and (`date_dim`.`d_dom` between asymmetric 1 and 3 or `date_dim`.`d_dom` between asymmetric 25 and 28) and (`household_demographics`.`hd_buy_potential` = '>10000' or `household_demographics`.`hd_buy_potential` = 'unknown') and `household_demographics`.`hd_vehicle_count` > 0 and case when `household_demographics`.`hd_vehicle_count` > 0 then cast(`household_demographics`.`hd_dep_count` as decimal(7, 7)) / `household_demographics`.`hd_vehicle_count` else null end > 1.2 and `date_dim`.`d_year` in (1999, 1999 + 1, 1999 + 2) and `store`.`s_county` in ('williamson county', 'williamson county', 'williamson county', 'williamson county', 'williamson county', 'williamson county', 'williamson county', 'williamson county')
group by `ss_ticket_number`, `ss_customer_sk`) as `dn`
where `ss_customer_sk` = `c_customer_sk` and `cnt` between asymmetric 15 and 20
order by `c_last_name`, `c_first_name`, `c_salutation`, `c_preferred_cust_flag` desc, `ss_ticket_number`