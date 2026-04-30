--Number of products by category:
--if the category name contains the word furniture, combine them into the category furniture;
--if the category name contains the word units, combine them into the category units;
--place all other products into the category other.
select
case when strpos(category, 'furniture') > 0 then 'furniture'
when strpos(category, 'units') > 0 then 'units' else 'other' end as category_new,
count (*) product_cnt
from `data-analytics-mate.DA.product`
group by 1
order by 2 desc;

--Get the last part of the size from the product description, for those products where the size is specified in the format width x length cm or height x width x length.
select
  category,
  case
    when strpos(short_description, 'cm') > 0
     and strpos(short_description, 'x') > 0
    then replace(
           right(
             short_description,
             strpos(reverse(short_description), 'x') - 1
           ),
           ' cm', ''
         )
  end as size,
  count(*) as product_cnt
from `data-analytics-mate.DA.product` as p
group by category, 2
order by 3 desc;

--Sessions where the language field contains English with refinements (e.g. en-us, en-gb).
--Group the results by these refinements and count the number of sessions for each refinement.
select
  right(language, 2) as en_type,
  count(*) as session_cnt
from `data-analytics-mate.DA.session_params` as acs
where language like 'en-%'  
group by 1
order by 2 desc;
