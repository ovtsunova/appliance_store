--
-- PostgreSQL database dump
--

\restrict e3NwuKeUofGtv8Eu0XFcriX4qGAL2A3Lc9P2tCQsqG2HEiJs79fzvbnqBIehEVU

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_account_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reviews DROP CONSTRAINT IF EXISTS reviews_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reviews DROP CONSTRAINT IF EXISTS reviews_product_id_fkey;
ALTER TABLE IF EXISTS ONLY public.products DROP CONSTRAINT IF EXISTS products_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.products DROP CONSTRAINT IF EXISTS products_brand_id_fkey;
ALTER TABLE IF EXISTS ONLY public.productcharacteristics DROP CONSTRAINT IF EXISTS productcharacteristics_product_id_fkey;
ALTER TABLE IF EXISTS ONLY public.orderstatushistory DROP CONSTRAINT IF EXISTS orderstatushistory_status_id_fkey;
ALTER TABLE IF EXISTS ONLY public.orderstatushistory DROP CONSTRAINT IF EXISTS orderstatushistory_order_id_fkey;
ALTER TABLE IF EXISTS ONLY public.orderstatushistory DROP CONSTRAINT IF EXISTS orderstatushistory_account_id_fkey;
ALTER TABLE IF EXISTS ONLY public.orders DROP CONSTRAINT IF EXISTS orders_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.orders DROP CONSTRAINT IF EXISTS orders_status_id_fkey;
ALTER TABLE IF EXISTS ONLY public.orders DROP CONSTRAINT IF EXISTS orders_paymenttype_id_fkey;
ALTER TABLE IF EXISTS ONLY public.orders DROP CONSTRAINT IF EXISTS orders_deliverytype_id_fkey;
ALTER TABLE IF EXISTS ONLY public.orders DROP CONSTRAINT IF EXISTS orders_address_id_fkey;
ALTER TABLE IF EXISTS ONLY public.orderdetails DROP CONSTRAINT IF EXISTS orderdetails_product_id_fkey;
ALTER TABLE IF EXISTS ONLY public.orderdetails DROP CONSTRAINT IF EXISTS orderdetails_order_id_fkey;
ALTER TABLE IF EXISTS ONLY public.favorites DROP CONSTRAINT IF EXISTS favorites_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.favorites DROP CONSTRAINT IF EXISTS favorites_product_id_fkey;
ALTER TABLE IF EXISTS ONLY public.categories DROP CONSTRAINT IF EXISTS categories_parentcategory_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cartitems DROP CONSTRAINT IF EXISTS cartitems_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cartitems DROP CONSTRAINT IF EXISTS cartitems_product_id_fkey;
ALTER TABLE IF EXISTS ONLY public.auditlog DROP CONSTRAINT IF EXISTS auditlog_account_id_fkey;
ALTER TABLE IF EXISTS ONLY public.addresses DROP CONSTRAINT IF EXISTS addresses_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.accounts DROP CONSTRAINT IF EXISTS accounts_role_id_fkey;
DROP TRIGGER IF EXISTS trg_users_audit ON public.users;
DROP TRIGGER IF EXISTS trg_set_default_order_status ON public.orders;
DROP TRIGGER IF EXISTS trg_reviews_audit ON public.reviews;
DROP TRIGGER IF EXISTS trg_restore_products_on_cancel ON public.orders;
DROP TRIGGER IF EXISTS trg_reduce_product_quantity ON public.orderdetails;
DROP TRIGGER IF EXISTS trg_products_audit ON public.products;
DROP TRIGGER IF EXISTS trg_orders_audit ON public.orders;
DROP TRIGGER IF EXISTS trg_check_account_email ON public.accounts;
DROP TRIGGER IF EXISTS trg_accounts_audit ON public.accounts;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_account_id_key;
ALTER TABLE IF EXISTS ONLY public.reviews DROP CONSTRAINT IF EXISTS uq_user_product_review;
ALTER TABLE IF EXISTS ONLY public.favorites DROP CONSTRAINT IF EXISTS uq_user_product_favorite;
ALTER TABLE IF EXISTS ONLY public.cartitems DROP CONSTRAINT IF EXISTS uq_user_product_cart;
ALTER TABLE IF EXISTS ONLY public.categories DROP CONSTRAINT IF EXISTS uq_category_parent;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_rolename_key;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_pkey;
ALTER TABLE IF EXISTS ONLY public.reviews DROP CONSTRAINT IF EXISTS reviews_pkey;
ALTER TABLE IF EXISTS ONLY public.products DROP CONSTRAINT IF EXISTS products_pkey;
ALTER TABLE IF EXISTS ONLY public.productcharacteristics DROP CONSTRAINT IF EXISTS productcharacteristics_pkey;
ALTER TABLE IF EXISTS ONLY public.paymenttypes DROP CONSTRAINT IF EXISTS paymenttypes_typename_key;
ALTER TABLE IF EXISTS ONLY public.paymenttypes DROP CONSTRAINT IF EXISTS paymenttypes_pkey;
ALTER TABLE IF EXISTS ONLY public.orderstatushistory DROP CONSTRAINT IF EXISTS orderstatushistory_pkey;
ALTER TABLE IF EXISTS ONLY public.orderstatuses DROP CONSTRAINT IF EXISTS orderstatuses_statusname_key;
ALTER TABLE IF EXISTS ONLY public.orderstatuses DROP CONSTRAINT IF EXISTS orderstatuses_pkey;
ALTER TABLE IF EXISTS ONLY public.orders DROP CONSTRAINT IF EXISTS orders_pkey;
ALTER TABLE IF EXISTS ONLY public.orderdetails DROP CONSTRAINT IF EXISTS orderdetails_pkey;
ALTER TABLE IF EXISTS ONLY public.favorites DROP CONSTRAINT IF EXISTS favorites_pkey;
ALTER TABLE IF EXISTS ONLY public.deliverytypes DROP CONSTRAINT IF EXISTS deliverytypes_typename_key;
ALTER TABLE IF EXISTS ONLY public.deliverytypes DROP CONSTRAINT IF EXISTS deliverytypes_pkey;
ALTER TABLE IF EXISTS ONLY public.categories DROP CONSTRAINT IF EXISTS categories_pkey;
ALTER TABLE IF EXISTS ONLY public.cartitems DROP CONSTRAINT IF EXISTS cartitems_pkey;
ALTER TABLE IF EXISTS ONLY public.brands DROP CONSTRAINT IF EXISTS brands_pkey;
ALTER TABLE IF EXISTS ONLY public.brands DROP CONSTRAINT IF EXISTS brands_brandname_key;
ALTER TABLE IF EXISTS ONLY public.auditlog DROP CONSTRAINT IF EXISTS auditlog_pkey;
ALTER TABLE IF EXISTS ONLY public.addresses DROP CONSTRAINT IF EXISTS addresses_pkey;
ALTER TABLE IF EXISTS ONLY public.accounts DROP CONSTRAINT IF EXISTS accounts_pkey;
ALTER TABLE IF EXISTS ONLY public.accounts DROP CONSTRAINT IF EXISTS accounts_email_key;
ALTER TABLE IF EXISTS public.users ALTER COLUMN id_user DROP DEFAULT;
ALTER TABLE IF EXISTS public.roles ALTER COLUMN id_role DROP DEFAULT;
ALTER TABLE IF EXISTS public.reviews ALTER COLUMN id_review DROP DEFAULT;
ALTER TABLE IF EXISTS public.products ALTER COLUMN id_product DROP DEFAULT;
ALTER TABLE IF EXISTS public.productcharacteristics ALTER COLUMN id_characteristic DROP DEFAULT;
ALTER TABLE IF EXISTS public.paymenttypes ALTER COLUMN id_paymenttype DROP DEFAULT;
ALTER TABLE IF EXISTS public.orderstatushistory ALTER COLUMN id_statushistory DROP DEFAULT;
ALTER TABLE IF EXISTS public.orderstatuses ALTER COLUMN id_status DROP DEFAULT;
ALTER TABLE IF EXISTS public.orders ALTER COLUMN id_order DROP DEFAULT;
ALTER TABLE IF EXISTS public.orderdetails ALTER COLUMN id_orderdetail DROP DEFAULT;
ALTER TABLE IF EXISTS public.favorites ALTER COLUMN id_favorite DROP DEFAULT;
ALTER TABLE IF EXISTS public.deliverytypes ALTER COLUMN id_deliverytype DROP DEFAULT;
ALTER TABLE IF EXISTS public.categories ALTER COLUMN id_category DROP DEFAULT;
ALTER TABLE IF EXISTS public.cartitems ALTER COLUMN id_cartitem DROP DEFAULT;
ALTER TABLE IF EXISTS public.brands ALTER COLUMN id_brand DROP DEFAULT;
ALTER TABLE IF EXISTS public.auditlog ALTER COLUMN id_auditlog DROP DEFAULT;
ALTER TABLE IF EXISTS public.addresses ALTER COLUMN id_address DROP DEFAULT;
ALTER TABLE IF EXISTS public.accounts ALTER COLUMN id_account DROP DEFAULT;
DROP VIEW IF EXISTS public.usersaccountsview;
DROP SEQUENCE IF EXISTS public.users_id_user_seq;
DROP VIEW IF EXISTS public.topusersview;
DROP VIEW IF EXISTS public.topproductsview;
DROP SEQUENCE IF EXISTS public.roles_id_role_seq;
DROP TABLE IF EXISTS public.roles;
DROP SEQUENCE IF EXISTS public.reviews_id_review_seq;
DROP TABLE IF EXISTS public.reviews;
DROP VIEW IF EXISTS public.productsview;
DROP SEQUENCE IF EXISTS public.products_id_product_seq;
DROP SEQUENCE IF EXISTS public.productcharacteristics_id_characteristic_seq;
DROP TABLE IF EXISTS public.productcharacteristics;
DROP SEQUENCE IF EXISTS public.paymenttypes_id_paymenttype_seq;
DROP VIEW IF EXISTS public.ordersview;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.paymenttypes;
DROP SEQUENCE IF EXISTS public.orderstatushistory_id_statushistory_seq;
DROP TABLE IF EXISTS public.orderstatushistory;
DROP SEQUENCE IF EXISTS public.orderstatuses_id_status_seq;
DROP TABLE IF EXISTS public.orderstatuses;
DROP SEQUENCE IF EXISTS public.orders_id_order_seq;
DROP VIEW IF EXISTS public.orderdetailsview;
DROP TABLE IF EXISTS public.products;
DROP TABLE IF EXISTS public.orders;
DROP SEQUENCE IF EXISTS public.orderdetails_id_orderdetail_seq;
DROP TABLE IF EXISTS public.orderdetails;
DROP SEQUENCE IF EXISTS public.favorites_id_favorite_seq;
DROP TABLE IF EXISTS public.favorites;
DROP SEQUENCE IF EXISTS public.deliverytypes_id_deliverytype_seq;
DROP TABLE IF EXISTS public.deliverytypes;
DROP SEQUENCE IF EXISTS public.categories_id_category_seq;
DROP TABLE IF EXISTS public.categories;
DROP SEQUENCE IF EXISTS public.cartitems_id_cartitem_seq;
DROP TABLE IF EXISTS public.cartitems;
DROP SEQUENCE IF EXISTS public.brands_id_brand_seq;
DROP TABLE IF EXISTS public.brands;
DROP SEQUENCE IF EXISTS public.auditlog_id_auditlog_seq;
DROP TABLE IF EXISTS public.auditlog;
DROP SEQUENCE IF EXISTS public.addresses_id_address_seq;
DROP TABLE IF EXISTS public.addresses;
DROP SEQUENCE IF EXISTS public.accounts_id_account_seq;
DROP TABLE IF EXISTS public.accounts;
DROP FUNCTION IF EXISTS public.set_default_order_status();
DROP FUNCTION IF EXISTS public.restore_products_on_cancel();
DROP PROCEDURE IF EXISTS public.registeruser(IN p_email character varying, IN p_password_hash character varying, IN p_role_id integer, IN p_last_name character varying, IN p_first_name character varying, IN p_patronymic character varying, IN p_phone_number character varying);
DROP FUNCTION IF EXISTS public.reduce_product_quantity();
DROP FUNCTION IF EXISTS public.log_changes();
DROP FUNCTION IF EXISTS public.get_user_avg_check_period(p_user_id integer, p_days integer);
DROP FUNCTION IF EXISTS public.get_top_users_period(p_days integer, p_limit integer);
DROP FUNCTION IF EXISTS public.get_top_products_period(p_days integer, p_limit integer);
DROP FUNCTION IF EXISTS public.get_income_period(p_days integer);
DROP FUNCTION IF EXISTS public.check_account_email();
DROP PROCEDURE IF EXISTS public.changeorderstatus(IN p_order_id integer, IN p_status_id integer, IN p_account_id integer);
DROP PROCEDURE IF EXISTS public.addproduct(IN p_product_name character varying, IN p_description text, IN p_model character varying, IN p_price numeric, IN p_stock_quantity integer, IN p_image_url text, IN p_warranty_period character varying, IN p_brand_id integer, IN p_category_id integer);
DROP EXTENSION IF EXISTS pgcrypto;
--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: addproduct(character varying, text, character varying, numeric, integer, text, character varying, integer, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.addproduct(IN p_product_name character varying, IN p_description text, IN p_model character varying, IN p_price numeric, IN p_stock_quantity integer, IN p_image_url text, IN p_warranty_period character varying, IN p_brand_id integer, IN p_category_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Brands WHERE ID_Brand = p_brand_id) THEN
        RAISE EXCEPTION 'Бренд с идентификатором % не найден.', p_brand_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Categories WHERE ID_Category = p_category_id) THEN
        RAISE EXCEPTION 'Категория с идентификатором % не найдена.', p_category_id;
    END IF;

    INSERT INTO Products (ProductName, Description, Model, Price, StockQuantity, ImageURL, WarrantyPeriod, Brand_ID, Category_ID)
    VALUES (p_product_name, p_description, p_model, p_price, p_stock_quantity, p_image_url, p_warranty_period, p_brand_id, p_category_id);
END;
$$;


--
-- Name: changeorderstatus(integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.changeorderstatus(IN p_order_id integer, IN p_status_id integer, IN p_account_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Orders WHERE ID_Order = p_order_id) THEN
        RAISE EXCEPTION 'Заказ с идентификатором % не найден.', p_order_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM OrderStatuses WHERE ID_Status = p_status_id) THEN
        RAISE EXCEPTION 'Статус с идентификатором % не найден.', p_status_id;
    END IF;

    UPDATE Orders
    SET Status_ID = p_status_id
    WHERE ID_Order = p_order_id;

    INSERT INTO OrderStatusHistory (Order_ID, Status_ID, Account_ID)
    VALUES (p_order_id, p_status_id, p_account_id);
END;
$$;


--
-- Name: check_account_email(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_account_email() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.Email NOT LIKE '%@%' THEN
        RAISE EXCEPTION 'Некорректный адрес электронной почты: должен содержать символ @.';
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: get_income_period(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_income_period(p_days integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_income NUMERIC;
BEGIN
    SELECT SUM(od.Price * od.Quantity) INTO total_income
    FROM Orders o
    JOIN OrderDetails od ON o.ID_Order = od.Order_ID
    WHERE o.OrderDate >= NOW() - (p_days || ' days')::INTERVAL;

    RETURN COALESCE(total_income, 0);
END;
$$;


--
-- Name: get_top_products_period(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_top_products_period(p_days integer, p_limit integer) RETURNS TABLE(product_id integer, product_name character varying, total_sold bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT pr.ID_Product,
           pr.ProductName::VARCHAR,
           SUM(od.Quantity) AS total_sold
    FROM OrderDetails od
    JOIN Orders o ON od.Order_ID = o.ID_Order
    JOIN Products pr ON od.Product_ID = pr.ID_Product
    WHERE o.OrderDate >= NOW() - (p_days || ' days')::INTERVAL
    GROUP BY pr.ID_Product, pr.ProductName
    ORDER BY total_sold DESC
    LIMIT p_limit;
END;
$$;


--
-- Name: get_top_users_period(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_top_users_period(p_days integer, p_limit integer) RETURNS TABLE(user_id integer, fullname character varying, total_spent numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT u.ID_User,
           (u.LastName || ' ' || u.FirstName || ' ' || COALESCE(u.Patronymic, ''))::VARCHAR,
           SUM(od.Price * od.Quantity) AS total_spent
    FROM Users u
    JOIN Orders o ON u.ID_User = o.User_ID
    JOIN OrderDetails od ON o.ID_Order = od.Order_ID
    WHERE o.OrderDate >= NOW() - (p_days || ' days')::INTERVAL
    GROUP BY u.ID_User, u.LastName, u.FirstName, u.Patronymic
    ORDER BY total_spent DESC
    LIMIT p_limit;
END;
$$;


--
-- Name: get_user_avg_check_period(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_user_avg_check_period(p_user_id integer, p_days integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    avg_check NUMERIC;
BEGIN
    SELECT AVG(sum_order) INTO avg_check
    FROM (
        SELECT SUM(od.Price * od.Quantity) AS sum_order
        FROM Orders o
        JOIN OrderDetails od ON o.ID_Order = od.Order_ID
        WHERE o.User_ID = p_user_id
          AND o.OrderDate >= NOW() - (p_days || ' days')::INTERVAL
        GROUP BY o.ID_Order
    ) sub;

    RETURN COALESCE(avg_check, 0);
END;
$$;


--
-- Name: log_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.log_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    key_field TEXT;
    key_value INT;
    current_account_id INT;
BEGIN
    SELECT column_name INTO key_field
    FROM information_schema.columns
    WHERE table_name = TG_TABLE_NAME
      AND column_name ILIKE 'id_%'
    ORDER BY ordinal_position
    LIMIT 1;

    BEGIN
        current_account_id := NULLIF(current_setting('app.current_account_id', true), '')::INT;
    EXCEPTION
        WHEN OTHERS THEN
            current_account_id := NULL;
    END;

    IF TG_OP = 'UPDATE' THEN
        EXECUTE format('SELECT ($1).%I', key_field) INTO key_value USING NEW;
        INSERT INTO AuditLog (ActionName, EntityName, EntityID, OldValue, NewValue, Account_ID)
        VALUES ('UPDATE', TG_TABLE_NAME, key_value, row_to_json(OLD), row_to_json(NEW), current_account_id);
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        EXECUTE format('SELECT ($1).%I', key_field) INTO key_value USING OLD;
        INSERT INTO AuditLog (ActionName, EntityName, EntityID, OldValue, Account_ID)
        VALUES ('DELETE', TG_TABLE_NAME, key_value, row_to_json(OLD), current_account_id);
        RETURN OLD;

    ELSIF TG_OP = 'INSERT' THEN
        EXECUTE format('SELECT ($1).%I', key_field) INTO key_value USING NEW;
        INSERT INTO AuditLog (ActionName, EntityName, EntityID, NewValue, Account_ID)
        VALUES ('INSERT', TG_TABLE_NAME, key_value, row_to_json(NEW), current_account_id);
        RETURN NEW;
    END IF;

    RETURN NULL;
END;
$_$;


--
-- Name: reduce_product_quantity(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reduce_product_quantity() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE Products
    SET StockQuantity = StockQuantity - NEW.Quantity
    WHERE ID_Product = NEW.Product_ID;

    IF (SELECT StockQuantity FROM Products WHERE ID_Product = NEW.Product_ID) < 0 THEN
        RAISE EXCEPTION 'Недостаточно товара на складе для Product_ID = %.', NEW.Product_ID;
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: registeruser(character varying, character varying, integer, character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.registeruser(IN p_email character varying, IN p_password_hash character varying, IN p_role_id integer, IN p_last_name character varying, IN p_first_name character varying, IN p_patronymic character varying, IN p_phone_number character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_account_id INT;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Roles WHERE ID_Role = p_role_id) THEN
        RAISE EXCEPTION 'Роль с идентификатором % не найдена.', p_role_id;
    END IF;

    INSERT INTO Accounts (Email, PasswordHash, Role_ID)
    VALUES (p_email, p_password_hash, p_role_id)
    RETURNING ID_Account INTO v_account_id;

    INSERT INTO Users (LastName, FirstName, Patronymic, PhoneNumber, Account_ID)
    VALUES (p_last_name, p_first_name, p_patronymic, p_phone_number, v_account_id);
END;
$$;


--
-- Name: restore_products_on_cancel(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.restore_products_on_cancel() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    cancelled_status_id INT;
BEGIN
    SELECT ID_Status INTO cancelled_status_id
    FROM OrderStatuses
    WHERE StatusName = 'Отменён'
    LIMIT 1;

    IF NEW.Status_ID <> OLD.Status_ID AND NEW.Status_ID = cancelled_status_id THEN
        UPDATE Products p
        SET StockQuantity = p.StockQuantity + od.Quantity
        FROM OrderDetails od
        WHERE od.Product_ID = p.ID_Product
          AND od.Order_ID = NEW.ID_Order;
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: set_default_order_status(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_default_order_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.Status_ID IS NULL THEN
        NEW.Status_ID := (SELECT ID_Status FROM OrderStatuses WHERE StatusName = 'Новый' LIMIT 1);
    END IF;
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id_account integer NOT NULL,
    email character varying(120) NOT NULL,
    passwordhash character varying(255) NOT NULL,
    registrationdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    isblocked boolean DEFAULT false NOT NULL,
    role_id integer NOT NULL
);


--
-- Name: accounts_id_account_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.accounts_id_account_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_account_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.accounts_id_account_seq OWNED BY public.accounts.id_account;


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addresses (
    id_address integer NOT NULL,
    country character varying(100) NOT NULL,
    city character varying(100) NOT NULL,
    street character varying(100) NOT NULL,
    house character varying(20) NOT NULL,
    apartment character varying(20),
    postalcode character varying(12) NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: addresses_id_address_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.addresses_id_address_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: addresses_id_address_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.addresses_id_address_seq OWNED BY public.addresses.id_address;


--
-- Name: auditlog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auditlog (
    id_auditlog integer NOT NULL,
    actionname character varying(50) NOT NULL,
    entityname character varying(100) NOT NULL,
    entityid integer NOT NULL,
    oldvalue jsonb,
    newvalue jsonb,
    actiondate timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    account_id integer
);


--
-- Name: auditlog_id_auditlog_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.auditlog_id_auditlog_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auditlog_id_auditlog_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.auditlog_id_auditlog_seq OWNED BY public.auditlog.id_auditlog;


--
-- Name: brands; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.brands (
    id_brand integer NOT NULL,
    brandname character varying(100) NOT NULL,
    countryoforigin character varying(100) NOT NULL,
    contactinfo character varying(200)
);


--
-- Name: brands_id_brand_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.brands_id_brand_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brands_id_brand_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.brands_id_brand_seq OWNED BY public.brands.id_brand;


--
-- Name: cartitems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cartitems (
    id_cartitem integer NOT NULL,
    quantity integer NOT NULL,
    addeddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    user_id integer NOT NULL,
    product_id integer NOT NULL,
    CONSTRAINT cartitems_quantity_check CHECK ((quantity > 0))
);


--
-- Name: cartitems_id_cartitem_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cartitems_id_cartitem_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cartitems_id_cartitem_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cartitems_id_cartitem_seq OWNED BY public.cartitems.id_cartitem;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id_category integer NOT NULL,
    categoryname character varying(100) NOT NULL,
    categorydescription text,
    parentcategory_id integer
);


--
-- Name: categories_id_category_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_category_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_category_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_category_seq OWNED BY public.categories.id_category;


--
-- Name: deliverytypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deliverytypes (
    id_deliverytype integer NOT NULL,
    typename character varying(100) NOT NULL,
    cost numeric(10,2) NOT NULL,
    estimateddeliverytime character varying(100) NOT NULL,
    CONSTRAINT deliverytypes_cost_check CHECK ((cost >= (0)::numeric))
);


--
-- Name: deliverytypes_id_deliverytype_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deliverytypes_id_deliverytype_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deliverytypes_id_deliverytype_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deliverytypes_id_deliverytype_seq OWNED BY public.deliverytypes.id_deliverytype;


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites (
    id_favorite integer NOT NULL,
    addeddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    user_id integer NOT NULL,
    product_id integer NOT NULL
);


--
-- Name: favorites_id_favorite_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.favorites_id_favorite_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favorites_id_favorite_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.favorites_id_favorite_seq OWNED BY public.favorites.id_favorite;


--
-- Name: orderdetails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orderdetails (
    id_orderdetail integer NOT NULL,
    quantity integer NOT NULL,
    price numeric(10,2) NOT NULL,
    order_id integer NOT NULL,
    product_id integer NOT NULL,
    CONSTRAINT orderdetails_price_check CHECK ((price > (0)::numeric)),
    CONSTRAINT orderdetails_quantity_check CHECK ((quantity > 0))
);


--
-- Name: orderdetails_id_orderdetail_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.orderdetails_id_orderdetail_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orderdetails_id_orderdetail_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.orderdetails_id_orderdetail_seq OWNED BY public.orderdetails.id_orderdetail;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    id_order integer NOT NULL,
    orderdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    totalamount numeric(10,2) NOT NULL,
    ordercomment text,
    user_id integer NOT NULL,
    address_id integer NOT NULL,
    deliverytype_id integer NOT NULL,
    paymenttype_id integer NOT NULL,
    status_id integer NOT NULL,
    CONSTRAINT orders_totalamount_check CHECK ((totalamount >= (0)::numeric))
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id_product integer NOT NULL,
    productname character varying(150) NOT NULL,
    description text,
    model character varying(100) NOT NULL,
    price numeric(10,2) NOT NULL,
    stockquantity integer NOT NULL,
    imageurl text,
    warrantyperiod character varying(50),
    brand_id integer NOT NULL,
    category_id integer NOT NULL,
    CONSTRAINT products_price_check CHECK ((price > (0)::numeric)),
    CONSTRAINT products_stockquantity_check CHECK ((stockquantity >= 0))
);


--
-- Name: orderdetailsview; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.orderdetailsview AS
 SELECT od.id_orderdetail AS "Код позиции",
    o.id_order AS "Код заказа",
    pr.productname AS "Товар",
    od.quantity AS "Количество",
    od.price AS "Цена за единицу",
    ((od.quantity)::numeric * od.price) AS "Сумма по позиции"
   FROM ((public.orderdetails od
     JOIN public.orders o ON ((od.order_id = o.id_order)))
     JOIN public.products pr ON ((od.product_id = pr.id_product)));


--
-- Name: orders_id_order_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.orders_id_order_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orders_id_order_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.orders_id_order_seq OWNED BY public.orders.id_order;


--
-- Name: orderstatuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orderstatuses (
    id_status integer NOT NULL,
    statusname character varying(40) NOT NULL
);


--
-- Name: orderstatuses_id_status_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.orderstatuses_id_status_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orderstatuses_id_status_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.orderstatuses_id_status_seq OWNED BY public.orderstatuses.id_status;


--
-- Name: orderstatushistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orderstatushistory (
    id_statushistory integer NOT NULL,
    statuschangedate timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    order_id integer NOT NULL,
    status_id integer NOT NULL,
    account_id integer
);


--
-- Name: orderstatushistory_id_statushistory_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.orderstatushistory_id_statushistory_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orderstatushistory_id_statushistory_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.orderstatushistory_id_statushistory_seq OWNED BY public.orderstatushistory.id_statushistory;


--
-- Name: paymenttypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paymenttypes (
    id_paymenttype integer NOT NULL,
    typename character varying(100) NOT NULL,
    description text
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id_user integer NOT NULL,
    lastname character varying(80) NOT NULL,
    firstname character varying(80) NOT NULL,
    patronymic character varying(80),
    phonenumber character varying(20) NOT NULL,
    account_id integer NOT NULL
);


--
-- Name: ordersview; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.ordersview AS
 SELECT o.id_order AS "Код заказа",
    o.orderdate AS "Дата заказа",
    (((u.lastname)::text || ' '::text) || (u.firstname)::text) AS "Покупатель",
    s.statusname AS "Статус",
    d.typename AS "Способ доставки",
    p.typename AS "Способ оплаты",
    ((((((a.city)::text || ', '::text) || (a.street)::text) || ' '::text) || (a.house)::text) || COALESCE((', кв. '::text || (a.apartment)::text), ''::text)) AS "Адрес доставки",
    o.totalamount AS "Итоговая сумма"
   FROM (((((public.orders o
     JOIN public.users u ON ((o.user_id = u.id_user)))
     JOIN public.orderstatuses s ON ((o.status_id = s.id_status)))
     JOIN public.deliverytypes d ON ((o.deliverytype_id = d.id_deliverytype)))
     JOIN public.paymenttypes p ON ((o.paymenttype_id = p.id_paymenttype)))
     JOIN public.addresses a ON ((o.address_id = a.id_address)));


--
-- Name: paymenttypes_id_paymenttype_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.paymenttypes_id_paymenttype_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: paymenttypes_id_paymenttype_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.paymenttypes_id_paymenttype_seq OWNED BY public.paymenttypes.id_paymenttype;


--
-- Name: productcharacteristics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.productcharacteristics (
    id_characteristic integer NOT NULL,
    characteristicname character varying(100) NOT NULL,
    characteristicvalue text NOT NULL,
    product_id integer NOT NULL
);


--
-- Name: productcharacteristics_id_characteristic_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.productcharacteristics_id_characteristic_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: productcharacteristics_id_characteristic_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.productcharacteristics_id_characteristic_seq OWNED BY public.productcharacteristics.id_characteristic;


--
-- Name: products_id_product_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_product_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_product_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_product_seq OWNED BY public.products.id_product;


--
-- Name: productsview; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.productsview AS
 SELECT pr.id_product AS "Код товара",
    pr.productname AS "Наименование товара",
    b.brandname AS "Бренд",
    c.categoryname AS "Категория",
    pr.model AS "Модель",
    pr.price AS "Цена",
    pr.stockquantity AS "Количество на складе"
   FROM ((public.products pr
     JOIN public.brands b ON ((pr.brand_id = b.id_brand)))
     JOIN public.categories c ON ((pr.category_id = c.id_category)));


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reviews (
    id_review integer NOT NULL,
    rating integer NOT NULL,
    comment text,
    reviewdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    user_id integer NOT NULL,
    product_id integer NOT NULL,
    CONSTRAINT reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


--
-- Name: reviews_id_review_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reviews_id_review_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reviews_id_review_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reviews_id_review_seq OWNED BY public.reviews.id_review;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id_role integer NOT NULL,
    rolename character varying(40) NOT NULL
);


--
-- Name: roles_id_role_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_role_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_role_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_role_seq OWNED BY public.roles.id_role;


--
-- Name: topproductsview; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.topproductsview AS
 SELECT pr.productname AS "Наименование товара",
    count(r.id_review) AS "Количество отзывов",
    round(avg(r.rating), 2) AS "Средняя оценка"
   FROM (public.products pr
     LEFT JOIN public.reviews r ON ((pr.id_product = r.product_id)))
  GROUP BY pr.productname
  ORDER BY (round(avg(r.rating), 2)) DESC, (count(r.id_review)) DESC;


--
-- Name: topusersview; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.topusersview AS
 SELECT u.id_user AS "Код пользователя",
    (((((u.lastname)::text || ' '::text) || (u.firstname)::text) || ' '::text) || (COALESCE(u.patronymic, ''::character varying))::text) AS "ФИО пользователя",
    count(o.id_order) AS "Количество заказов",
    sum(((od.quantity)::numeric * od.price)) AS "Сумма покупок"
   FROM ((public.users u
     JOIN public.orders o ON ((u.id_user = o.user_id)))
     JOIN public.orderdetails od ON ((o.id_order = od.order_id)))
  GROUP BY u.id_user, u.lastname, u.firstname, u.patronymic
  ORDER BY (sum(((od.quantity)::numeric * od.price))) DESC;


--
-- Name: users_id_user_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_user_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_user_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_user_seq OWNED BY public.users.id_user;


--
-- Name: usersaccountsview; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.usersaccountsview AS
 SELECT u.id_user AS "Код пользователя",
    u.lastname AS "Фамилия",
    u.firstname AS "Имя",
    a.email AS "Электронная почта",
    r.rolename AS "Роль",
    a.isblocked AS "Заблокирован"
   FROM ((public.users u
     JOIN public.accounts a ON ((u.account_id = a.id_account)))
     JOIN public.roles r ON ((a.role_id = r.id_role)));


--
-- Name: accounts id_account; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts ALTER COLUMN id_account SET DEFAULT nextval('public.accounts_id_account_seq'::regclass);


--
-- Name: addresses id_address; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses ALTER COLUMN id_address SET DEFAULT nextval('public.addresses_id_address_seq'::regclass);


--
-- Name: auditlog id_auditlog; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auditlog ALTER COLUMN id_auditlog SET DEFAULT nextval('public.auditlog_id_auditlog_seq'::regclass);


--
-- Name: brands id_brand; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brands ALTER COLUMN id_brand SET DEFAULT nextval('public.brands_id_brand_seq'::regclass);


--
-- Name: cartitems id_cartitem; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cartitems ALTER COLUMN id_cartitem SET DEFAULT nextval('public.cartitems_id_cartitem_seq'::regclass);


--
-- Name: categories id_category; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id_category SET DEFAULT nextval('public.categories_id_category_seq'::regclass);


--
-- Name: deliverytypes id_deliverytype; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deliverytypes ALTER COLUMN id_deliverytype SET DEFAULT nextval('public.deliverytypes_id_deliverytype_seq'::regclass);


--
-- Name: favorites id_favorite; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites ALTER COLUMN id_favorite SET DEFAULT nextval('public.favorites_id_favorite_seq'::regclass);


--
-- Name: orderdetails id_orderdetail; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orderdetails ALTER COLUMN id_orderdetail SET DEFAULT nextval('public.orderdetails_id_orderdetail_seq'::regclass);


--
-- Name: orders id_order; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders ALTER COLUMN id_order SET DEFAULT nextval('public.orders_id_order_seq'::regclass);


--
-- Name: orderstatuses id_status; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orderstatuses ALTER COLUMN id_status SET DEFAULT nextval('public.orderstatuses_id_status_seq'::regclass);


--
-- Name: orderstatushistory id_statushistory; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orderstatushistory ALTER COLUMN id_statushistory SET DEFAULT nextval('public.orderstatushistory_id_statushistory_seq'::regclass);


--
-- Name: paymenttypes id_paymenttype; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paymenttypes ALTER COLUMN id_paymenttype SET DEFAULT nextval('public.paymenttypes_id_paymenttype_seq'::regclass);


--
-- Name: productcharacteristics id_characteristic; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productcharacteristics ALTER COLUMN id_characteristic SET DEFAULT nextval('public.productcharacteristics_id_characteristic_seq'::regclass);


--
-- Name: products id_product; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id_product SET DEFAULT nextval('public.products_id_product_seq'::regclass);


--
-- Name: reviews id_review; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews ALTER COLUMN id_review SET DEFAULT nextval('public.reviews_id_review_seq'::regclass);


--
-- Name: roles id_role; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id_role SET DEFAULT nextval('public.roles_id_role_seq'::regclass);


--
-- Name: users id_user; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id_user SET DEFAULT nextval('public.users_id_user_seq'::regclass);


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.accounts (id_account, email, passwordhash, registrationdate, isblocked, role_id) FROM stdin;
1	admin@tehnostore.ru	$2a$06$wM7T.AzrgNfdHlmb7FkljetVcuupI0ojO7.lCy1.UgyCdA67KD182	2026-04-02 21:54:45.732476	f	1
2	ivanov@tehnostore.ru	$2a$06$dQgeAUPJZq6b/gA3lliLkeN4PTrPFRO5dak5EXmHNeQzPZkeMlUWi	2026-04-02 21:54:45.732476	f	2
3	petrova@tehnostore.ru	$2a$06$sgFy5osJFbrn1qLBUzxjfepLeE4Tm4uoF0xIC41IbUSQw3RZZO1UO	2026-04-02 21:54:45.732476	f	2
4	corruold@gmail.com	$2a$06$RCFdlPTt.1LRNMrRL2uZpe1Lp1qZC0rpBxvH6uEfoOD/9Xq4idBjy	2026-04-02 22:37:03.671945	f	1
\.


--
-- Data for Name: addresses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.addresses (id_address, country, city, street, house, apartment, postalcode, user_id) FROM stdin;
1	Россия	Москва	Тверская	10	15	101000	2
2	Россия	Санкт-Петербург	Невский проспект	25	\N	190000	3
3	Россия	Москва	Ленинский проспект	55	42	119334	2
4	Россия	Москва	Пушкина	2	111	115945	4
\.


--
-- Data for Name: auditlog; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.auditlog (id_auditlog, actionname, entityname, entityid, oldvalue, newvalue, actiondate, account_id) FROM stdin;
1	INSERT	accounts	4	\N	{"email": "corruold@gmail.com", "role_id": 2, "isblocked": false, "id_account": 4, "passwordhash": "$2a$06$kuRo9hsindpXRr86iAdQau/V.T/h3iHD0FtJNCo/abjRL2O9MUvH2", "registrationdate": "2026-04-02T22:37:03.671945"}	2026-04-02 22:37:03.671945	\N
2	INSERT	users	4	\N	{"id_user": 4, "lastname": "Овцунова", "firstname": "Анастасия", "account_id": 4, "patronymic": "Алексеевна", "phonenumber": "79154487678"}	2026-04-02 22:37:03.671945	\N
3	UPDATE	accounts	4	{"email": "corruold@gmail.com", "role_id": 2, "isblocked": false, "id_account": 4, "passwordhash": "$2a$06$kuRo9hsindpXRr86iAdQau/V.T/h3iHD0FtJNCo/abjRL2O9MUvH2", "registrationdate": "2026-04-02T22:37:03.671945"}	{"email": "corruold@gmail.com", "role_id": 2, "isblocked": false, "id_account": 4, "passwordhash": "$2a$06$RCFdlPTt.1LRNMrRL2uZpe1Lp1qZC0rpBxvH6uEfoOD/9Xq4idBjy", "registrationdate": "2026-04-02T22:37:03.671945"}	2026-04-02 22:37:56.883905	\N
4	INSERT	orders	3	\N	{"user_id": 4, "id_order": 3, "orderdate": "2026-04-03T00:25:36.520909", "status_id": 1, "address_id": 4, "totalamount": 51998.00, "ordercomment": "берегите", "paymenttype_id": 2, "deliverytype_id": 1}	2026-04-03 00:25:36.520909	\N
5	UPDATE	products	4	{"model": "BFL524", "price": 25999.00, "brand_id": 3, "imageurl": "https://static.insales-cdn.com/images/products/1/2667/602311275/BFL524MB0.jpeg", "id_product": 4, "category_id": 5, "description": "Встраиваемая микроволновая печь с функцией гриля.", "productname": "Микроволновая печь Bosch BFL524", "stockquantity": 12, "warrantyperiod": "12 месяцев"}	{"model": "BFL524", "price": 25999.00, "brand_id": 3, "imageurl": "https://static.insales-cdn.com/images/products/1/2667/602311275/BFL524MB0.jpeg", "id_product": 4, "category_id": 5, "description": "Встраиваемая микроволновая печь с функцией гриля.", "productname": "Микроволновая печь Bosch BFL524", "stockquantity": 10, "warrantyperiod": "12 месяцев"}	2026-04-03 00:25:36.520909	\N
6	UPDATE	orders	3	{"user_id": 4, "id_order": 3, "orderdate": "2026-04-03T00:25:36.520909", "status_id": 1, "address_id": 4, "totalamount": 51998.00, "ordercomment": "берегите", "paymenttype_id": 2, "deliverytype_id": 1}	{"user_id": 4, "id_order": 3, "orderdate": "2026-04-03T00:25:36.520909", "status_id": 4, "address_id": 4, "totalamount": 51998.00, "ordercomment": "берегите", "paymenttype_id": 2, "deliverytype_id": 1}	2026-04-03 00:26:24.202379	\N
7	UPDATE	products	4	{"model": "BFL524", "price": 25999.00, "brand_id": 3, "imageurl": "https://static.insales-cdn.com/images/products/1/2667/602311275/BFL524MB0.jpeg", "id_product": 4, "category_id": 5, "description": "Встраиваемая микроволновая печь с функцией гриля.", "productname": "Микроволновая печь Bosch BFL524", "stockquantity": 10, "warrantyperiod": "12 месяцев"}	{"model": "BFL524", "price": 25999.00, "brand_id": 3, "imageurl": "https://static.insales-cdn.com/images/products/1/2667/602311275/BFL524MB0.jpeg", "id_product": 4, "category_id": 5, "description": "Встраиваемая микроволновая печь с функцией гриля.", "productname": "Микроволновая печь Bosch BFL524", "stockquantity": 12, "warrantyperiod": "12 месяцев"}	2026-04-03 00:26:24.202379	\N
8	INSERT	orders	4	\N	{"user_id": 4, "id_order": 4, "orderdate": "2026-04-03T00:27:00.824223", "status_id": 1, "address_id": 4, "totalamount": 54999.00, "ordercomment": "Боже", "paymenttype_id": 2, "deliverytype_id": 2}	2026-04-03 00:27:00.824223	\N
9	UPDATE	products	2	{"model": "F2V5", "price": 54999.00, "brand_id": 2, "imageurl": "https://ir.ozone.ru/s3/multimedia-1-e/c400/7736464850.jpg", "id_product": 2, "category_id": 3, "description": "Фронтальная стиральная машина с инверторным двигателем.", "productname": "Стиральная машина LG F2V5", "stockquantity": 15, "warrantyperiod": "24 месяца"}	{"model": "F2V5", "price": 54999.00, "brand_id": 2, "imageurl": "https://ir.ozone.ru/s3/multimedia-1-e/c400/7736464850.jpg", "id_product": 2, "category_id": 3, "description": "Фронтальная стиральная машина с инверторным двигателем.", "productname": "Стиральная машина LG F2V5", "stockquantity": 14, "warrantyperiod": "24 месяца"}	2026-04-03 00:27:00.824223	\N
10	INSERT	reviews	3	\N	{"rating": 5, "comment": "Очень крутой холодос", "user_id": 4, "id_review": 3, "product_id": 1, "reviewdate": "2026-04-03T00:56:37.221689"}	2026-04-03 00:56:37.221689	\N
11	UPDATE	reviews	3	{"rating": 5, "comment": "Очень крутой холодос", "user_id": 4, "id_review": 3, "product_id": 1, "reviewdate": "2026-04-03T00:56:37.221689"}	{"rating": 5, "comment": "Очень крутой холодоссссс", "user_id": 4, "id_review": 3, "product_id": 1, "reviewdate": "2026-04-03T00:56:48.753219"}	2026-04-03 00:56:48.753219	\N
12	DELETE	reviews	3	{"rating": 5, "comment": "Очень крутой холодоссссс", "user_id": 4, "id_review": 3, "product_id": 1, "reviewdate": "2026-04-03T00:56:48.753219"}	\N	2026-04-03 00:56:49.991307	\N
13	INSERT	reviews	4	\N	{"rating": 5, "comment": "Супер", "user_id": 4, "id_review": 4, "product_id": 2, "reviewdate": "2026-04-03T01:09:52.342174"}	2026-04-03 01:09:52.342174	\N
14	DELETE	reviews	4	{"rating": 5, "comment": "Супер", "user_id": 4, "id_review": 4, "product_id": 2, "reviewdate": "2026-04-03T01:09:52.342174"}	\N	2026-04-03 01:15:45.353612	\N
15	INSERT	reviews	5	\N	{"rating": 5, "comment": "Просто имбааа", "user_id": 4, "id_review": 5, "product_id": 2, "reviewdate": "2026-04-03T01:15:55.091878"}	2026-04-03 01:15:55.091878	\N
16	UPDATE	accounts	3	{"email": "petrova@tehnostore.ru", "role_id": 2, "isblocked": false, "id_account": 3, "passwordhash": "$2a$06$sgFy5osJFbrn1qLBUzxjfepLeE4Tm4uoF0xIC41IbUSQw3RZZO1UO", "registrationdate": "2026-04-02T21:54:45.732476"}	{"email": "petrova@tehnostore.ru", "role_id": 2, "isblocked": true, "id_account": 3, "passwordhash": "$2a$06$sgFy5osJFbrn1qLBUzxjfepLeE4Tm4uoF0xIC41IbUSQw3RZZO1UO", "registrationdate": "2026-04-02T21:54:45.732476"}	2026-04-03 01:33:16.201968	1
17	UPDATE	accounts	3	{"email": "petrova@tehnostore.ru", "role_id": 2, "isblocked": true, "id_account": 3, "passwordhash": "$2a$06$sgFy5osJFbrn1qLBUzxjfepLeE4Tm4uoF0xIC41IbUSQw3RZZO1UO", "registrationdate": "2026-04-02T21:54:45.732476"}	{"email": "petrova@tehnostore.ru", "role_id": 2, "isblocked": false, "id_account": 3, "passwordhash": "$2a$06$sgFy5osJFbrn1qLBUzxjfepLeE4Tm4uoF0xIC41IbUSQw3RZZO1UO", "registrationdate": "2026-04-02T21:54:45.732476"}	2026-04-03 01:33:17.99211	1
18	DELETE	reviews	2	{"rating": 4, "comment": "Хороший телевизор, но меню немного медленное.", "user_id": 3, "id_review": 2, "product_id": 3, "reviewdate": "2026-03-26T14:30:00"}	\N	2026-04-03 01:33:31.236941	1
19	UPDATE	orders	4	{"user_id": 4, "id_order": 4, "orderdate": "2026-04-03T00:27:00.824223", "status_id": 1, "address_id": 4, "totalamount": 54999.00, "ordercomment": "Боже", "paymenttype_id": 2, "deliverytype_id": 2}	{"user_id": 4, "id_order": 4, "orderdate": "2026-04-03T00:27:00.824223", "status_id": 2, "address_id": 4, "totalamount": 54999.00, "ordercomment": "Боже", "paymenttype_id": 2, "deliverytype_id": 2}	2026-04-03 02:09:47.591633	1
20	UPDATE	accounts	4	{"email": "corruold@gmail.com", "role_id": 2, "isblocked": false, "id_account": 4, "passwordhash": "$2a$06$RCFdlPTt.1LRNMrRL2uZpe1Lp1qZC0rpBxvH6uEfoOD/9Xq4idBjy", "registrationdate": "2026-04-02T22:37:03.671945"}	{"email": "corruold@gmail.com", "role_id": 1, "isblocked": false, "id_account": 4, "passwordhash": "$2a$06$RCFdlPTt.1LRNMrRL2uZpe1Lp1qZC0rpBxvH6uEfoOD/9Xq4idBjy", "registrationdate": "2026-04-02T22:37:03.671945"}	2026-04-03 02:10:09.49604	1
\.


--
-- Data for Name: brands; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.brands (id_brand, brandname, countryoforigin, contactinfo) FROM stdin;
1	Samsung	Южная Корея	contact@samsung.example
2	LG	Южная Корея	contact@lg.example
3	Bosch	Германия	contact@bosch.example
4	Sony	Япония	contact@sony.example
\.


--
-- Data for Name: cartitems; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cartitems (id_cartitem, quantity, addeddate, user_id, product_id) FROM stdin;
1	1	2026-03-28 09:00:00	2	2
2	2	2026-03-28 09:05:00	3	4
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.categories (id_category, categoryname, categorydescription, parentcategory_id) FROM stdin;
1	Бытовая техника	Основная категория бытовой техники	\N
2	Холодильники	Холодильники и морозильные камеры	1
3	Стиральные машины	Стиральные машины и сушильные автоматы	1
4	Телевизоры	Телевизоры и мультимедийные устройства	1
5	Малая техника	Микроволновые печи, чайники и другая малая техника	1
\.


--
-- Data for Name: deliverytypes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.deliverytypes (id_deliverytype, typename, cost, estimateddeliverytime) FROM stdin;
1	Курьер	500.00	1-2 дня
2	Самовывоз	0.00	в день заказа
3	Почта	300.00	3-7 дней
\.


--
-- Data for Name: favorites; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.favorites (id_favorite, addeddate, user_id, product_id) FROM stdin;
1	2026-03-10 11:00:00	2	3
2	2026-03-11 12:00:00	3	1
3	2026-04-02 23:33:30.45832	4	1
5	2026-04-02 23:51:28.012886	4	2
\.


--
-- Data for Name: orderdetails; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.orderdetails (id_orderdetail, quantity, price, order_id, product_id) FROM stdin;
1	1	79999.00	1	1
2	1	89999.00	2	3
3	1	25999.00	2	4
4	2	25999.00	3	4
5	1	54999.00	4	2
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.orders (id_order, orderdate, totalamount, ordercomment, user_id, address_id, deliverytype_id, paymenttype_id, status_id) FROM stdin;
1	2026-03-15 10:30:00	79999.00	Доставить после 18:00	2	1	1	1	3
2	2026-03-20 15:00:00	115998.00	Позвонить перед доставкой	3	2	1	3	2
3	2026-04-03 00:25:36.520909	51998.00	берегите	4	4	1	2	4
4	2026-04-03 00:27:00.824223	54999.00	Боже	4	4	2	2	2
\.


--
-- Data for Name: orderstatuses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.orderstatuses (id_status, statusname) FROM stdin;
1	Новый
2	В обработке
3	Доставлен
4	Отменён
\.


--
-- Data for Name: orderstatushistory; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.orderstatushistory (id_statushistory, statuschangedate, order_id, status_id, account_id) FROM stdin;
1	2026-03-15 10:30:00	1	1	1
2	2026-03-16 09:00:00	1	2	1
3	2026-03-17 18:30:00	1	3	1
4	2026-03-20 15:00:00	2	1	1
5	2026-03-21 12:00:00	2	2	1
6	2026-04-03 00:25:36.520909	3	1	4
7	2026-04-03 00:26:24.202379	3	4	4
8	2026-04-03 00:27:00.824223	4	1	4
9	2026-04-03 02:09:47.591633	4	2	1
\.


--
-- Data for Name: paymenttypes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.paymenttypes (id_paymenttype, typename, description) FROM stdin;
1	Банковская карта	Оплата дебетовой или кредитной картой
2	Наличные	Оплата наличными при получении или самовывозе
3	Онлайн-перевод	Оплата банковским переводом через интернет
\.


--
-- Data for Name: productcharacteristics; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.productcharacteristics (id_characteristic, characteristicname, characteristicvalue, product_id) FROM stdin;
1	Объём	367 л	1
2	Класс энергопотребления	A++	1
3	Загрузка	8 кг	2
4	Скорость отжима	1200 об/мин	2
5	Диагональ экрана	55 дюймов	3
6	Разрешение	3840x2160	3
7	Мощность	900 Вт	4
8	Тип управления	Сенсорное	4
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.products (id_product, productname, description, model, price, stockquantity, imageurl, warrantyperiod, brand_id, category_id) FROM stdin;
1	Холодильник Samsung RB37A	Двухкамерный холодильник с системой No Frost.	RB37A	79999.00	20	https://www.bt-system.ru/thumbnails/435x375_ecaeb6aa22200f5bddc806e7083cfe42.png	24 месяца	1	2
3	Телевизор Sony Bravia 55X80L	Смарт-телевизор 55 дюймов с поддержкой 4K.	55X80L	89999.00	10	https://ru-electronics.ru/wa-data/public/shop/products/07/32/3207/images/9742/9742.970.jpg	24 месяца	4	4
4	Микроволновая печь Bosch BFL524	Встраиваемая микроволновая печь с функцией гриля.	BFL524	25999.00	12	https://static.insales-cdn.com/images/products/1/2667/602311275/BFL524MB0.jpeg	12 месяцев	3	5
2	Стиральная машина LG F2V5	Фронтальная стиральная машина с инверторным двигателем.	F2V5	54999.00	14	https://ir.ozone.ru/s3/multimedia-1-e/c400/7736464850.jpg	24 месяца	2	3
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reviews (id_review, rating, comment, reviewdate, user_id, product_id) FROM stdin;
1	5	Отличный холодильник, работает тихо и хорошо охлаждает.	2026-03-25 12:00:00	2	1
5	5	Просто имбааа	2026-04-03 01:15:55.091878	4	2
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles (id_role, rolename) FROM stdin;
1	Администратор
2	Покупатель
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id_user, lastname, firstname, patronymic, phonenumber, account_id) FROM stdin;
1	Админов	Алексей	Сергеевич	79990000001	1
2	Иванов	Иван	Иванович	79990000002	2
3	Петрова	Анна	Олеговна	79990000003	3
4	Овцунова	Анастасия	Алексеевна	79154487678	4
\.


--
-- Name: accounts_id_account_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.accounts_id_account_seq', 4, true);


--
-- Name: addresses_id_address_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.addresses_id_address_seq', 4, true);


--
-- Name: auditlog_id_auditlog_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.auditlog_id_auditlog_seq', 20, true);


--
-- Name: brands_id_brand_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.brands_id_brand_seq', 5, true);


--
-- Name: cartitems_id_cartitem_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cartitems_id_cartitem_seq', 5, true);


--
-- Name: categories_id_category_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categories_id_category_seq', 5, true);


--
-- Name: deliverytypes_id_deliverytype_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.deliverytypes_id_deliverytype_seq', 3, true);


--
-- Name: favorites_id_favorite_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.favorites_id_favorite_seq', 5, true);


--
-- Name: orderdetails_id_orderdetail_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.orderdetails_id_orderdetail_seq', 5, true);


--
-- Name: orders_id_order_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.orders_id_order_seq', 4, true);


--
-- Name: orderstatuses_id_status_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.orderstatuses_id_status_seq', 4, true);


--
-- Name: orderstatushistory_id_statushistory_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.orderstatushistory_id_statushistory_seq', 9, true);


--
-- Name: paymenttypes_id_paymenttype_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.paymenttypes_id_paymenttype_seq', 3, true);


--
-- Name: productcharacteristics_id_characteristic_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.productcharacteristics_id_characteristic_seq', 8, true);


--
-- Name: products_id_product_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.products_id_product_seq', 4, true);


--
-- Name: reviews_id_review_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reviews_id_review_seq', 5, true);


--
-- Name: roles_id_role_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.roles_id_role_seq', 2, true);


--
-- Name: users_id_user_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_user_seq', 4, true);


--
-- Name: accounts accounts_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_email_key UNIQUE (email);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id_account);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id_address);


--
-- Name: auditlog auditlog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auditlog
    ADD CONSTRAINT auditlog_pkey PRIMARY KEY (id_auditlog);


--
-- Name: brands brands_brandname_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_brandname_key UNIQUE (brandname);


--
-- Name: brands brands_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (id_brand);


--
-- Name: cartitems cartitems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cartitems
    ADD CONSTRAINT cartitems_pkey PRIMARY KEY (id_cartitem);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id_category);


--
-- Name: deliverytypes deliverytypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deliverytypes
    ADD CONSTRAINT deliverytypes_pkey PRIMARY KEY (id_deliverytype);


--
-- Name: deliverytypes deliverytypes_typename_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deliverytypes
    ADD CONSTRAINT deliverytypes_typename_key UNIQUE (typename);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id_favorite);


--
-- Name: orderdetails orderdetails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orderdetails
    ADD CONSTRAINT orderdetails_pkey PRIMARY KEY (id_orderdetail);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id_order);


--
-- Name: orderstatuses orderstatuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orderstatuses
    ADD CONSTRAINT orderstatuses_pkey PRIMARY KEY (id_status);


--
-- Name: orderstatuses orderstatuses_statusname_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orderstatuses
    ADD CONSTRAINT orderstatuses_statusname_key UNIQUE (statusname);


--
-- Name: orderstatushistory orderstatushistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orderstatushistory
    ADD CONSTRAINT orderstatushistory_pkey PRIMARY KEY (id_statushistory);


--
-- Name: paymenttypes paymenttypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paymenttypes
    ADD CONSTRAINT paymenttypes_pkey PRIMARY KEY (id_paymenttype);


--
-- Name: paymenttypes paymenttypes_typename_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paymenttypes
    ADD CONSTRAINT paymenttypes_typename_key UNIQUE (typename);


--
-- Name: productcharacteristics productcharacteristics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productcharacteristics
    ADD CONSTRAINT productcharacteristics_pkey PRIMARY KEY (id_characteristic);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id_product);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id_review);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id_role);


--
-- Name: roles roles_rolename_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_rolename_key UNIQUE (rolename);


--
-- Name: categories uq_category_parent; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT uq_category_parent UNIQUE (categoryname, parentcategory_id);


--
-- Name: cartitems uq_user_product_cart; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cartitems
    ADD CONSTRAINT uq_user_product_cart UNIQUE (user_id, product_id);


--
-- Name: favorites uq_user_product_favorite; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT uq_user_product_favorite UNIQUE (user_id, product_id);


--
-- Name: reviews uq_user_product_review; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT uq_user_product_review UNIQUE (user_id, product_id);


--
-- Name: users users_account_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_account_id_key UNIQUE (account_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id_user);


--
-- Name: accounts trg_accounts_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_accounts_audit AFTER INSERT OR DELETE OR UPDATE ON public.accounts FOR EACH ROW EXECUTE FUNCTION public.log_changes();


--
-- Name: accounts trg_check_account_email; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_check_account_email BEFORE INSERT OR UPDATE ON public.accounts FOR EACH ROW EXECUTE FUNCTION public.check_account_email();


--
-- Name: orders trg_orders_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_orders_audit AFTER INSERT OR DELETE OR UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.log_changes();


--
-- Name: products trg_products_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_products_audit AFTER INSERT OR DELETE OR UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.log_changes();


--
-- Name: orderdetails trg_reduce_product_quantity; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_reduce_product_quantity AFTER INSERT ON public.orderdetails FOR EACH ROW EXECUTE FUNCTION public.reduce_product_quantity();


--
-- Name: orders trg_restore_products_on_cancel; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_restore_products_on_cancel AFTER UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.restore_products_on_cancel();


--
-- Name: reviews trg_reviews_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_reviews_audit AFTER INSERT OR DELETE OR UPDATE ON public.reviews FOR EACH ROW EXECUTE FUNCTION public.log_changes();


--
-- Name: orders trg_set_default_order_status; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_set_default_order_status BEFORE INSERT ON public.orders FOR EACH ROW EXECUTE FUNCTION public.set_default_order_status();


--
-- Name: users trg_users_audit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_users_audit AFTER INSERT OR DELETE OR UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.log_changes();


--
-- Name: accounts accounts_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id_role);


--
-- Name: addresses addresses_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id_user);


--
-- Name: auditlog auditlog_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auditlog
    ADD CONSTRAINT auditlog_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id_account);


--
-- Name: cartitems cartitems_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cartitems
    ADD CONSTRAINT cartitems_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id_product) ON DELETE CASCADE;


--
-- Name: cartitems cartitems_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cartitems
    ADD CONSTRAINT cartitems_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id_user) ON DELETE CASCADE;


--
-- Name: categories categories_parentcategory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_parentcategory_id_fkey FOREIGN KEY (parentcategory_id) REFERENCES public.categories(id_category);


--
-- Name: favorites favorites_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id_product) ON DELETE CASCADE;


--
-- Name: favorites favorites_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id_user) ON DELETE CASCADE;


--
-- Name: orderdetails orderdetails_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orderdetails
    ADD CONSTRAINT orderdetails_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id_order) ON DELETE CASCADE;


--
-- Name: orderdetails orderdetails_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orderdetails
    ADD CONSTRAINT orderdetails_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id_product);


--
-- Name: orders orders_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.addresses(id_address);


--
-- Name: orders orders_deliverytype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_deliverytype_id_fkey FOREIGN KEY (deliverytype_id) REFERENCES public.deliverytypes(id_deliverytype);


--
-- Name: orders orders_paymenttype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_paymenttype_id_fkey FOREIGN KEY (paymenttype_id) REFERENCES public.paymenttypes(id_paymenttype);


--
-- Name: orders orders_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.orderstatuses(id_status);


--
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id_user);


--
-- Name: orderstatushistory orderstatushistory_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orderstatushistory
    ADD CONSTRAINT orderstatushistory_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id_account);


--
-- Name: orderstatushistory orderstatushistory_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orderstatushistory
    ADD CONSTRAINT orderstatushistory_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id_order) ON DELETE CASCADE;


--
-- Name: orderstatushistory orderstatushistory_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orderstatushistory
    ADD CONSTRAINT orderstatushistory_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.orderstatuses(id_status);


--
-- Name: productcharacteristics productcharacteristics_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productcharacteristics
    ADD CONSTRAINT productcharacteristics_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id_product) ON DELETE CASCADE;


--
-- Name: products products_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_brand_id_fkey FOREIGN KEY (brand_id) REFERENCES public.brands(id_brand);


--
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id_category);


--
-- Name: reviews reviews_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id_product) ON DELETE CASCADE;


--
-- Name: reviews reviews_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id_user) ON DELETE CASCADE;


--
-- Name: users users_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id_account);


--
-- PostgreSQL database dump complete
--

\unrestrict e3NwuKeUofGtv8Eu0XFcriX4qGAL2A3Lc9P2tCQsqG2HEiJs79fzvbnqBIehEVU

