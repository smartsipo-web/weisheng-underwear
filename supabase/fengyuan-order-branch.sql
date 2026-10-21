alter table public.orders add column if not exists branch_name text;
create or replace function public.create_order_with_branch(p_order_no text,p_source_key text,p_source_name text,p_discount_rate numeric,p_customer_name text,p_delivery text,p_total integer,p_item_count integer,p_items jsonb,p_customer_contact text default null,p_branch_name text default null) returns jsonb language plpgsql set search_path='' as $$
declare r jsonb;
begin
if p_source_key='group-fengyuan' then
if nullif(trim(p_customer_name),'') is null then raise exception 'invalid_customer_name'; end if;
if nullif(trim(p_customer_contact),'') is null then raise exception 'phone_required'; end if;
if p_branch_name is null or p_branch_name not in ('成功店','水源店','后里店') then raise exception 'branch_required'; end if;
end if;
r:=public.create_order_with_contact(p_order_no,p_source_key,p_source_name,p_discount_rate,p_customer_name,p_delivery,p_total,p_item_count,p_items,p_customer_contact);
if p_source_key='group-fengyuan' then update public.orders set branch_name=p_branch_name where id=(r->>'id')::bigint and order_no=p_order_no; if not found then raise exception 'new_order_not_found'; end if; end if;
return r;
end; $$;
revoke all on function public.create_order_with_branch(text,text,text,numeric,text,text,integer,integer,jsonb,text,text) from public,anon,authenticated;
grant execute on function public.create_order_with_branch(text,text,text,numeric,text,text,integer,integer,jsonb,text,text) to service_role;
