-- Scripts adapted from https://github.com/opengento/magento2-downgrade-ee-ce


SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS
    `temando_checkout_address`,
    `temando_collection_point_search`,
    `temando_order`, `temando_order_collection_point`,
    `temando_order_pickup_location`,
    `temando_pickup_location_search`,
    `temando_quote_collection_point`,
    `temando_quote_pickup_location`,
    `temando_rma_shipment`,
    `temando_shipment`,
    `email_catalog`
;


-- Drop EE tables

-- ------------------------------------------------------ --
-- Here we drop the tables without the foreign key check, --
-- because unless your custom development refers to them, --
-- it won't have any interest to keep them in CE          --
-- ------------------------------------------------------ --

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS
    `magento_acknowledged_bulk`,
    `magento_banner`,
    `magento_banner_catalogrule`,
    `magento_banner_content`,
    `magento_banner_customersegment`,
    `magento_banner_salesrule`,
    `magento_bulk`,
    `magento_catalogevent_event`,
    `magento_catalogevent_event_image`,
    `magento_catalogpermissions`,
    `magento_catalogpermissions_index`,
    `magento_catalogpermissions_index_product`,
    `magento_catalogpermissions_index_product_replica`,
    `magento_catalogpermissions_index_product_tmp`,
    `magento_catalogpermissions_index_replica`,
    `magento_catalogpermissions_index_tmp`,
    `magento_customerbalance`,
    `magento_customerbalance_history`,
    `magento_customercustomattributes_sales_flat_order`,
    `magento_customercustomattributes_sales_flat_order_address`,
    `magento_customercustomattributes_sales_flat_quote`,
    `magento_customercustomattributes_sales_flat_quote_address`,
    `magento_customersegment_customer`,
    `magento_customersegment_event`,
    `magento_customersegment_segment`,
    `magento_customersegment_website`,
    `magento_giftcard_amount`,
    `magento_giftcardaccount`,
    `magento_giftcardaccount_history`,
    `magento_giftcardaccount_pool`,
    `magento_giftregistry_data`,
    `magento_giftregistry_entity`,
    `magento_giftregistry_item`,
    `magento_giftregistry_item_option`,
    `magento_giftregistry_label`,
    `magento_giftregistry_person`,
    `magento_giftregistry_type`,
    `magento_giftregistry_type_info`,
    `magento_giftwrapping`,
    `magento_giftwrapping_store_attributes`,
    `magento_giftwrapping_website`,
    `magento_invitation`,
    `magento_invitation_status_history`,
    `magento_invitation_track`,
    `magento_logging_event`,
    `magento_logging_event_changes`,
    `magento_operation`,
    `magento_reminder_rule`,
    `magento_reminder_rule_coupon`,
    `magento_reminder_rule_log`,
    `magento_reminder_rule_website`,
    `magento_reminder_template`,
    `magento_reward`,
    `magento_reward_history`,
    `magento_reward_rate`,
    `magento_reward_salesrule`,
    `magento_rma`,
    `magento_rma_grid`,
    `magento_rma_item_eav_attribute`,
    `magento_rma_item_eav_attribute_website`,
    `magento_rma_item_entity`,
    `magento_rma_item_entity_datetime`,
    `magento_rma_item_entity_decimal`,
    `magento_rma_item_entity_int`,
    `magento_rma_item_entity_text`,
    `magento_rma_item_entity_varchar`,
    `magento_rma_item_form_attribute`,
    `magento_rma_shipping_label`,
    `magento_rma_status_history`,
    `magento_sales_creditmemo_grid_archive`,
    `magento_sales_invoice_grid_archive`,
    `magento_sales_order_grid_archive`,
    `magento_sales_shipment_grid_archive`,
    `magento_salesrule_filter`,
    `magento_scheduled_operations`,
    `magento_targetrule`,
    `magento_targetrule_customersegment`,
    `magento_targetrule_index`,
    `magento_targetrule_index_crosssell`,
    `magento_targetrule_index_crosssell_product`,
    `magento_targetrule_index_related`,
    `magento_targetrule_index_related_product`,
    `magento_targetrule_index_upsell`,
    `magento_targetrule_index_upsell_product`,
    `magento_targetrule_product`,
    `magento_versionscms_hierarchy_lock`,
    `magento_versionscms_hierarchy_metadata`,
    `magento_versionscms_hierarchy_node`,
    `magento_versionscms_increment`,
    `visual_merchandiser_rule`;
SET FOREIGN_KEY_CHECKS = 1;

-- Enable `block_id` for block store
ALTER TABLE `cms_block_store` ADD COLUMN `block_id` SMALLINT(6) NOT NULL COMMENT 'Entity ID';

-- Enable `page_id` for page store
ALTER TABLE `cms_page_store` ADD COLUMN `page_id` SMALLINT(6) NOT NULL COMMENT 'Entity ID';

-- Clean duplicates for cms block
DELETE e
FROM `cms_block` e
         LEFT OUTER JOIN (
    SELECT MAX(`updated_in`) as `last_updated_in`, `block_id`
    FROM `cms_block`
    GROUP BY `block_id`
) AS p
                         ON e.`block_id` = p.`block_id` AND e.`updated_in` = p.`last_updated_in`
WHERE p.`last_updated_in` IS NULL;

-- Clean duplicates for cms page
DELETE e
FROM `cms_page` e
         LEFT OUTER JOIN (
    SELECT MAX(`updated_in`) as `last_updated_in`, `page_id`
    FROM `cms_page`
    GROUP BY `page_id`
) AS p
                         ON e.`page_id` = p.`page_id` AND e.`updated_in` = p.`last_updated_in`
WHERE p.`last_updated_in` IS NULL;

-- Populate `block_id` column for block store
UPDATE `cms_block_store` v INNER JOIN `cms_block` e ON v.`row_id` = e.`row_id`
SET v.`block_id` = e.`block_id`
WHERE 1;

-- Populate `page_id` column for page store
UPDATE `cms_page_store` v INNER JOIN `cms_page` e ON v.`row_id` = e.`row_id`
SET v.`page_id` = e.`page_id`
WHERE 1;

-- Update the `block_id` relation link for block store
ALTER TABLE `cms_block_store`
    DROP FOREIGN KEY `CMS_BLOCK_STORE_ROW_ID_CMS_BLOCK_ROW_ID`,
    DROP PRIMARY KEY,
    DROP COLUMN `row_id`,
    ADD PRIMARY KEY (`block_id`,`store_id`);

SET FOREIGN_KEY_CHECKS = 0; # Many third party modules refers to the `block_id` column, we prevent blocking.
ALTER TABLE `cms_block`
    DROP FOREIGN KEY `CMS_BLOCK_BLOCK_ID_SEQUENCE_CMS_BLOCK_SEQUENCE_VALUE`;
ALTER TABLE `cms_block`
    DROP COLUMN `row_id`,
    DROP COLUMN `created_in`,
    DROP COLUMN `updated_in`,
    ADD PRIMARY KEY (`block_id`),
    MODIFY COLUMN `block_id` SMALLINT(6) NOT NULL AUTO_INCREMENT COMMENT 'Entity ID';
SET FOREIGN_KEY_CHECKS = 1;

-- Update the `page_id` relation link for page store
ALTER TABLE `cms_page_store`
    DROP FOREIGN KEY `CMS_PAGE_STORE_ROW_ID_CMS_PAGE_ROW_ID`,
    DROP PRIMARY KEY,
    DROP COLUMN `row_id`,
    ADD PRIMARY KEY (`page_id`,`store_id`);

SET FOREIGN_KEY_CHECKS = 0; # Many third party modules refers to the `page_id` column, we prevent blocking.
ALTER TABLE `cms_page`
    DROP FOREIGN KEY `CMS_PAGE_PAGE_ID_SEQUENCE_CMS_PAGE_SEQUENCE_VALUE`,
    DROP COLUMN `row_id`,
    DROP COLUMN `created_in`,
    DROP COLUMN `updated_in`,
    ADD PRIMARY KEY (`page_id`),
    MODIFY COLUMN `page_id` SMALLINT(6) NOT NULL AUTO_INCREMENT COMMENT 'Entity ID';
SET FOREIGN_KEY_CHECKS = 1;

-- Foreign keys cms block
ALTER TABLE `cms_block_store`
    ADD CONSTRAINT `CMS_BLOCK_STORE_BLOCK_ID_CMS_BLOCK_BLOCK_ID` FOREIGN KEY (`block_id`) REFERENCES `cms_block` (`block_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

-- Foreign keys cms page
ALTER TABLE `cms_page_store`
    ADD CONSTRAINT `CMS_PAGE_STORE_PAGE_ID_CMS_PAGE_PAGE_ID` FOREIGN KEY (`page_id`) REFERENCES `cms_page` (`page_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

-- ----------------
-- Drop sequence --
-- ----------------

DROP TABLE `sequence_cms_page`,`sequence_cms_block`;

SET FOREIGN_KEY_CHECKS = 0;
-- Enable `entity_id` column for catalog product entity

ALTER TABLE `catalog_product_entity_datetime`
    ADD COLUMN `entity_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Entity ID';
ALTER TABLE `catalog_product_entity_decimal`
    ADD COLUMN `entity_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Entity ID';
ALTER TABLE `catalog_product_entity_gallery`
    ADD COLUMN `entity_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Entity ID';
ALTER TABLE `catalog_product_entity_int`
    ADD COLUMN `entity_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Entity ID';
ALTER TABLE `catalog_product_entity_media_gallery_value`
    ADD COLUMN `entity_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Entity ID';
ALTER TABLE `catalog_product_entity_media_gallery_value_to_entity`
    ADD COLUMN `entity_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Entity ID';
ALTER TABLE `catalog_product_entity_text`
    ADD COLUMN `entity_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Entity ID';
ALTER TABLE `catalog_product_entity_tier_price`
    ADD COLUMN `entity_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Entity ID';
ALTER TABLE `catalog_product_entity_varchar`
    ADD COLUMN `entity_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Entity ID';

-- Enable `parent_id` & `parent_product_id` columns for catalog product bundle

ALTER TABLE `catalog_product_bundle_option`
    ADD COLUMN `new_parent_id` INT(10) UNSIGNED NOT NULL COMMENT 'Parent ID';
ALTER TABLE `catalog_product_bundle_option_value`
    ADD COLUMN `new_parent_product_id` INT(10) UNSIGNED NOT NULL COMMENT 'Parent Product ID';
ALTER TABLE `catalog_product_bundle_selection`
    ADD COLUMN `new_parent_product_id` INT(10) UNSIGNED NOT NULL COMMENT 'Parent Product ID';
ALTER TABLE `catalog_product_bundle_selection_price`
    ADD COLUMN `new_parent_product_id` INT(10) UNSIGNED NOT NULL COMMENT 'Parent Product ID';

-- Enable `product_id` column for downloadable

ALTER TABLE `downloadable_link`
    ADD COLUMN `new_product_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Product ID';
ALTER TABLE `downloadable_sample`
    ADD COLUMN `new_product_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Product ID';

-- Enable `product_id` column for product link

ALTER TABLE `catalog_product_link`
    ADD COLUMN `new_product_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Product ID';

-- Enable `product_id` column for product option

ALTER TABLE `catalog_product_option`
    ADD COLUMN `new_product_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Product ID';

-- Enable `child_id` & `parent_id` columns for product relation

ALTER TABLE `catalog_product_relation`
    ADD COLUMN `new_parent_id` INT(10) UNSIGNED NOT NULL COMMENT 'Parent ID';

-- Enable `product_id` column for super attribute

ALTER TABLE `catalog_product_super_attribute`
    ADD COLUMN `new_product_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Product ID';

-- Enable `parent_id` column for super link

ALTER TABLE `catalog_product_super_link`
    ADD COLUMN `new_parent_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Parent ID';

-- Clean duplicate for catalog product entity

DELETE e
FROM `catalog_product_entity` e
         LEFT OUTER JOIN (
    SELECT MAX(`updated_in`) as `last_updated_in`, `entity_id`
    FROM `catalog_product_entity`
    GROUP BY `entity_id`
) AS p
                         ON e.`entity_id` = p.`entity_id` AND e.`updated_in` = p.`last_updated_in`
WHERE p.`last_updated_in` IS NULL;

-- Populate `entity_id` column for catalog product entity

UPDATE `catalog_product_entity_datetime` v INNER JOIN `catalog_product_entity` e ON v.`row_id` = e.`row_id`
SET v.`entity_id` = e.`entity_id`
WHERE 1;
UPDATE `catalog_product_entity_decimal` v INNER JOIN `catalog_product_entity` e ON v.`row_id` = e.`row_id`
SET v.`entity_id` = e.`entity_id`
WHERE 1;
UPDATE `catalog_product_entity_gallery` v INNER JOIN `catalog_product_entity` e ON v.`row_id` = e.`row_id`
SET v.`entity_id` = e.`entity_id`
WHERE 1;
UPDATE `catalog_product_entity_int` v INNER JOIN `catalog_product_entity` e ON v.`row_id` = e.`row_id`
SET v.`entity_id` = e.`entity_id`
WHERE 1;
UPDATE `catalog_product_entity_media_gallery_value` v INNER JOIN `catalog_product_entity` e ON v.`row_id` = e.`row_id`
SET v.`entity_id` = e.`entity_id`
WHERE 1;
UPDATE `catalog_product_entity_media_gallery_value_to_entity` v INNER JOIN `catalog_product_entity` e ON v.`row_id` = e.`row_id`
SET v.`entity_id` = e.`entity_id`
WHERE 1;
UPDATE `catalog_product_entity_text` v INNER JOIN `catalog_product_entity` e ON v.`row_id` = e.`row_id`
SET v.`entity_id` = e.`entity_id`
WHERE 1;
UPDATE `catalog_product_entity_tier_price` v INNER JOIN `catalog_product_entity` e ON v.`row_id` = e.`row_id`
SET v.`entity_id` = e.`entity_id`
WHERE 1;
UPDATE `catalog_product_entity_varchar` v INNER JOIN `catalog_product_entity` e ON v.`row_id` = e.`row_id`
SET v.`entity_id` = e.`entity_id`
WHERE 1;

-- Populate `parent_id` & `parent_product_id` columns for catalog product bundle

UPDATE `catalog_product_bundle_option` v INNER JOIN `catalog_product_entity` e ON v.`parent_id` = e.`row_id`
SET v.`new_parent_id` = e.`entity_id`
WHERE 1;
UPDATE `catalog_product_bundle_option_value` v INNER JOIN `catalog_product_entity` e ON v.`parent_product_id` = e.`row_id`
SET v.`new_parent_product_id` = e.`entity_id`
WHERE 1;
UPDATE `catalog_product_bundle_selection` v INNER JOIN `catalog_product_entity` e ON v.`parent_product_id` = e.`row_id`
SET v.`new_parent_product_id` = e.`entity_id`
WHERE 1;
UPDATE `catalog_product_bundle_selection_price` v INNER JOIN `catalog_product_entity` e ON v.`parent_product_id` = e.`row_id`
SET v.`new_parent_product_id` = e.`entity_id`
WHERE 1;

-- Populate `product_id` column for downloadable

UPDATE `downloadable_link` v INNER JOIN `catalog_product_entity` e ON v.`product_id` = e.`row_id`
SET v.`new_product_id` = e.`entity_id`
WHERE 1;
UPDATE `downloadable_sample` v INNER JOIN `catalog_product_entity` e ON v.`product_id` = e.`row_id`
SET v.`new_product_id` = e.`entity_id`
WHERE 1;

-- Populate `product_id` column for product link

UPDATE `catalog_product_link` v INNER JOIN `catalog_product_entity` e ON v.`product_id` = e.`row_id`
SET v.`new_product_id` = e.`entity_id`
WHERE 1;

-- Populate `product_id` column for product option

UPDATE `catalog_product_option` v INNER JOIN `catalog_product_entity` e ON v.`product_id` = e.`row_id`
SET v.`new_product_id` = e.`entity_id`
WHERE 1;

-- Populate `parent_id` columns for product relation

UPDATE `catalog_product_relation` v INNER JOIN `catalog_product_entity` e ON v.`parent_id` = e.`row_id`
SET v.`new_parent_id` = e.`entity_id`
WHERE 1;

-- Populate `product_id` column for super attribute

UPDATE `catalog_product_super_attribute` v INNER JOIN `catalog_product_entity` e ON v.`product_id` = e.`row_id`
SET v.`new_product_id` = e.`entity_id`
WHERE 1;

-- Populate `product_id` column for super link

UPDATE `catalog_product_super_link` v INNER JOIN `catalog_product_entity` e ON v.`parent_id` = e.`row_id`
SET v.`new_parent_id` = e.`entity_id`
WHERE 1;

-- -------------
-- Super Link --
-- -------------

ALTER TABLE `catalog_product_super_link`
    DROP FOREIGN KEY `CAT_PRD_SPR_LNK_PARENT_ID_CAT_PRD_ENTT_ROW_ID`,
    DROP FOREIGN KEY `CAT_PRD_SPR_LNK_PRD_ID_SEQUENCE_PRD_SEQUENCE_VAL`,
    DROP INDEX `CATALOG_PRODUCT_SUPER_LINK_PARENT_ID`,
    DROP INDEX `CATALOG_PRODUCT_SUPER_LINK_PRODUCT_ID_PARENT_ID`,
    DROP COLUMN `parent_id`,
    CHANGE COLUMN `new_parent_id` `parent_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Parent ID',
    ADD INDEX `CATALOG_PRODUCT_SUPER_LINK_PARENT_ID` (`product_id`),
    ADD CONSTRAINT `CATALOG_PRODUCT_SUPER_LINK_PRODUCT_ID_PARENT_ID` UNIQUE KEY (`product_id`,`parent_id`);

-- ------------------
-- Super Attribute --
-- ------------------

ALTER TABLE `catalog_product_super_attribute`
    DROP FOREIGN KEY `CAT_PRD_SPR_ATTR_PRD_ID_CAT_PRD_ENTT_ROW_ID`,
    DROP INDEX `CATALOG_PRODUCT_SUPER_ATTRIBUTE_PRODUCT_ID_ATTRIBUTE_ID`,
    DROP COLUMN `product_id`,
    CHANGE COLUMN `new_product_id` `product_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Product ID',
    ADD CONSTRAINT `CATALOG_PRODUCT_SUPER_ATTRIBUTE_PRODUCT_ID_ATTRIBUTE_ID` UNIQUE KEY (`product_id`,`attribute_id`);

-- -------------------
-- Product Relation --
-- -------------------

ALTER TABLE `catalog_product_relation`
    DROP FOREIGN KEY `CATALOG_PRODUCT_RELATION_PARENT_ID_CATALOG_PRODUCT_ENTITY_ROW_ID`,
    DROP FOREIGN KEY `CAT_PRD_RELATION_CHILD_ID_SEQUENCE_PRD_SEQUENCE_VAL`,
    DROP PRIMARY KEY,
    DROP COLUMN `parent_id`,
    CHANGE COLUMN `new_parent_id` `parent_id` INT(10) UNSIGNED NOT NULL COMMENT 'Parent ID',
    ADD PRIMARY KEY (`parent_id`,`child_id`);

-- -----------------
-- Product Option --
-- -----------------

ALTER TABLE `catalog_product_option`
    DROP FOREIGN KEY `CATALOG_PRODUCT_OPTION_PRODUCT_ID_CATALOG_PRODUCT_ENTITY_ROW_ID`,
    DROP INDEX `CATALOG_PRODUCT_OPTION_PRODUCT_ID`,
    DROP COLUMN `product_id`,
    CHANGE COLUMN `new_product_id` `product_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Product ID',
    ADD INDEX `CATALOG_PRODUCT_OPTION_PRODUCT_ID` (`product_id`);

-- ---------------
-- Product Link --
-- ---------------

ALTER TABLE `catalog_product_link`
    DROP FOREIGN KEY `CATALOG_PRODUCT_LINK_PRODUCT_ID_CATALOG_PRODUCT_ENTITY_ROW_ID`,
    DROP FOREIGN KEY `CAT_PRD_LNK_LNKED_PRD_ID_SEQUENCE_PRD_SEQUENCE_VAL`,
    DROP INDEX `CATALOG_PRODUCT_LINK_PRODUCT_ID`,
    DROP INDEX `CATALOG_PRODUCT_LINK_LINK_TYPE_ID_PRODUCT_ID_LINKED_PRODUCT_ID`,
    DROP COLUMN `product_id`,
    CHANGE COLUMN `new_product_id` `product_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Product ID',
    ADD INDEX `CATALOG_PRODUCT_LINK_PRODUCT_ID` (`product_id`),
    ADD CONSTRAINT `CATALOG_PRODUCT_LINK_LINK_TYPE_ID_PRODUCT_ID_LINKED_PRODUCT_ID` UNIQUE KEY (`link_type_id`,`product_id`,`linked_product_id`);

-- ---------------
-- Downloadable --
-- ---------------

ALTER TABLE `downloadable_link`
    DROP FOREIGN KEY `DOWNLOADABLE_LINK_PRODUCT_ID_CATALOG_PRODUCT_ENTITY_ROW_ID`,
    DROP INDEX `DOWNLOADABLE_LINK_PRODUCT_ID_SORT_ORDER`,
    DROP COLUMN `product_id`,
    CHANGE COLUMN `new_product_id` `product_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Product ID',
    ADD INDEX `DOWNLOADABLE_LINK_PRODUCT_ID_SORT_ORDER` (`product_id`,`sort_order`);

ALTER TABLE `downloadable_sample`
    DROP FOREIGN KEY `DOWNLOADABLE_SAMPLE_PRODUCT_ID_CATALOG_PRODUCT_ENTITY_ROW_ID`,
    DROP INDEX `DOWNLOADABLE_SAMPLE_PRODUCT_ID`,
    DROP COLUMN `product_id`,
    CHANGE COLUMN `new_product_id` `product_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Product ID',
    ADD INDEX `DOWNLOADABLE_SAMPLE_PRODUCT_ID` (`product_id`);

-- -----------------
-- Product Bundle --
-- -----------------

ALTER TABLE `catalog_product_bundle_selection_price`
    DROP FOREIGN KEY `CAT_PRD_BNDL_SELECTION_PRICE_PARENT_PRD_ID_CAT_PRD_ENTT_ROW_ID`,
    DROP FOREIGN KEY `CAT_PRD_BNDL_SELECTION_PRICE_WS_ID_STORE_WS_WS_ID`,
    DROP FOREIGN KEY `FK_AE9FDBF7988FB6BE3E04D91DA2CFB273`,
    DROP PRIMARY KEY,
    DROP COLUMN `parent_product_id`,
    CHANGE COLUMN `new_parent_product_id` `parent_product_id` INT(10) UNSIGNED NOT NULL COMMENT 'Parent Product ID',
    ADD PRIMARY KEY (`selection_id`,`parent_product_id`,`website_id`);

ALTER TABLE `catalog_product_bundle_selection`
    DROP FOREIGN KEY `CAT_PRD_BNDL_SELECTION_OPT_ID_SEQUENCE_PRD_BNDL_OPT_SEQUENCE_VAL`,
    DROP FOREIGN KEY `CAT_PRD_BNDL_SELECTION_PARENT_PRD_ID_CAT_PRD_ENTT_ROW_ID`,
    DROP FOREIGN KEY `CAT_PRD_BNDL_SELECTION_PRD_ID_SEQUENCE_PRD_SEQUENCE_VAL`,
    DROP FOREIGN KEY `FK_606117FEB5F50D0182CEC9D260C05DD2`,
    DROP PRIMARY KEY,
    DROP COLUMN `parent_product_id`,
    CHANGE COLUMN `new_parent_product_id` `parent_product_id` INT(10) UNSIGNED NOT NULL COMMENT 'Parent Product ID',
    MODIFY COLUMN `selection_id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Selection ID',
    ADD PRIMARY KEY (`selection_id`);

ALTER TABLE `catalog_product_bundle_option`
    DROP FOREIGN KEY `CAT_PRD_BNDL_OPT_OPT_ID_SEQUENCE_PRD_BNDL_OPT_SEQUENCE_VAL`,
    DROP FOREIGN KEY `CAT_PRD_BNDL_OPT_PARENT_ID_CAT_PRD_ENTT_ROW_ID`,
    DROP INDEX `CATALOG_PRODUCT_BUNDLE_OPTION_PARENT_ID`,
    DROP PRIMARY KEY,
    DROP COLUMN `parent_id`,
    CHANGE COLUMN `new_parent_id` `parent_id` INT(10) UNSIGNED NOT NULL COMMENT 'Parent ID',
    ADD INDEX `CATALOG_PRODUCT_BUNDLE_OPTION_PARENT_ID` (`parent_id`),
    MODIFY COLUMN `option_id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Option ID',
    ADD PRIMARY KEY (`option_id`);

ALTER TABLE `catalog_product_bundle_option_value`
    DROP FOREIGN KEY `CAT_PRD_BNDL_OPT_VAL_OPT_ID_SEQUENCE_PRD_BNDL_OPT_SEQUENCE_VAL`,
    DROP FOREIGN KEY `CAT_PRD_BNDL_OPT_VAL_PARENT_PRD_ID_CAT_PRD_ENTT_ROW_ID`,
    DROP INDEX `CAT_PRD_BNDL_OPT_VAL_PARENT_PRD_ID_CAT_PRD_ENTT_ROW_ID`,
    DROP INDEX `CAT_PRD_BNDL_OPT_VAL_OPT_ID_PARENT_PRD_ID_STORE_ID`,
    DROP COLUMN `parent_product_id`,
    CHANGE COLUMN `new_parent_product_id` `parent_product_id` INT(10) UNSIGNED NOT NULL COMMENT 'Parent Product ID',
    ADD CONSTRAINT `CAT_PRD_BNDL_OPT_VAL_OPT_ID_PARENT_PRD_ID_STORE_ID` UNIQUE KEY (`option_id`,`parent_product_id`,`store_id`),
    ADD CONSTRAINT `CAT_PRD_BNDL_OPT_VAL_OPT_ID_CAT_PRD_BNDL_OPT_OPT_ID` FOREIGN KEY (`option_id`) REFERENCES `catalog_product_bundle_option` (`option_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

-- ------------------------------------------------------------------
-- Update the `entity_id` relation link for catalog product entity --
-- ------------------------------------------------------------------

-- Datetime
ALTER TABLE `catalog_product_entity_datetime`
    DROP FOREIGN KEY `CAT_PRD_ENTT_DTIME_ROW_ID_CAT_PRD_ENTT_ROW_ID`,
    DROP INDEX `CATALOG_PRODUCT_ENTITY_DATETIME_ROW_ID_ATTRIBUTE_ID_STORE_ID`,
    ADD CONSTRAINT `CATALOG_PRODUCT_ENTITY_DATETIME_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` UNIQUE KEY (`entity_id`,`attribute_id`,`store_id`),
    DROP COLUMN `row_id`;

-- Decimal
ALTER TABLE `catalog_product_entity_decimal`
    DROP FOREIGN KEY `CAT_PRD_ENTT_DEC_ROW_ID_CAT_PRD_ENTT_ROW_ID`,
    DROP INDEX `CATALOG_PRODUCT_ENTITY_DECIMAL_ROW_ID_ATTRIBUTE_ID_STORE_ID`,
    ADD CONSTRAINT `CATALOG_PRODUCT_ENTITY_DECIMAL_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` UNIQUE KEY (`entity_id`,`attribute_id`,`store_id`),
    DROP COLUMN `row_id`;

-- Int
ALTER TABLE `catalog_product_entity_int`
    DROP FOREIGN KEY `CATALOG_PRODUCT_ENTITY_INT_ROW_ID_CATALOG_PRODUCT_ENTITY_ROW_ID`,
    DROP INDEX `CATALOG_PRODUCT_ENTITY_INT_ROW_ID_ATTRIBUTE_ID_STORE_ID`,
    ADD CONSTRAINT `CATALOG_PRODUCT_ENTITY_INT_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` UNIQUE KEY (`entity_id`,`attribute_id`,`store_id`),
    DROP COLUMN `row_id`;

-- Text
ALTER TABLE `catalog_product_entity_text`
    DROP FOREIGN KEY `CATALOG_PRODUCT_ENTITY_TEXT_ROW_ID_CATALOG_PRODUCT_ENTITY_ROW_ID`,
    DROP INDEX `CATALOG_PRODUCT_ENTITY_TEXT_ROW_ID_ATTRIBUTE_ID_STORE_ID`,
    ADD CONSTRAINT `CATALOG_PRODUCT_ENTITY_TEXT_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` UNIQUE KEY (`entity_id`,`attribute_id`,`store_id`),
    DROP COLUMN `row_id`;

-- Varchar
ALTER TABLE `catalog_product_entity_varchar`
    DROP FOREIGN KEY `CAT_PRD_ENTT_VCHR_ROW_ID_CAT_PRD_ENTT_ROW_ID`,
    DROP INDEX `CATALOG_PRODUCT_ENTITY_VARCHAR_ROW_ID_ATTRIBUTE_ID_STORE_ID`,
    ADD CONSTRAINT `CATALOG_PRODUCT_ENTITY_VARCHAR_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` UNIQUE KEY (`entity_id`,`attribute_id`,`store_id`),
    DROP COLUMN `row_id`;

-- Gallery value to entity
ALTER TABLE `catalog_product_entity_media_gallery_value_to_entity`
    DROP FOREIGN KEY `CAT_PRD_ENTT_MDA_GLR_VAL_TO_ENTT_ROW_ID_CAT_PRD_ENTT_ROW_ID`,
    DROP INDEX `CAT_PRD_ENTT_MDA_GLR_VAL_TO_ENTT_VAL_ID_ROW_ID`,
    ADD CONSTRAINT `CAT_PRD_ENTT_MDA_GLR_VAL_TO_ENTT_VAL_ID_ENTT_ID` UNIQUE KEY (`value_id`,`entity_id`),
    DROP COLUMN `row_id`;

-- Gallery value
ALTER TABLE `catalog_product_entity_media_gallery_value`
    DROP FOREIGN KEY `CAT_PRD_ENTT_MDA_GLR_VAL_ROW_ID_CAT_PRD_ENTT_ROW_ID`,
    DROP INDEX `CATALOG_PRODUCT_ENTITY_MEDIA_GALLERY_VALUE_ROW_ID`,
    ADD INDEX `CATALOG_PRODUCT_ENTITY_MEDIA_GALLERY_VALUE_ENTITY_ID` (`entity_id`),
    ADD CONSTRAINT `CAT_PRD_ENTT_MDA_GLR_VAL_ENTT_ID_VAL_ID_STORE_ID` UNIQUE KEY (`entity_id`,`value_id`,`store_id`),
    DROP COLUMN `row_id`;

-- Gallery
ALTER TABLE `catalog_product_entity_gallery`
    DROP FOREIGN KEY `CAT_PRD_ENTT_GLR_ROW_ID_CAT_PRD_ENTT_ROW_ID`,
    DROP INDEX `CATALOG_PRODUCT_ENTITY_GALLERY_ROW_ID`,
    DROP INDEX `CATALOG_PRODUCT_ENTITY_GALLERY_ROW_ID_ATTRIBUTE_ID_STORE_ID`,
    ADD INDEX `CATALOG_PRODUCT_ENTITY_GALLERY_ENTITY_ID` (`entity_id`),
    ADD CONSTRAINT `CATALOG_PRODUCT_ENTITY_GALLERY_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` UNIQUE KEY (`entity_id`,`attribute_id`,`store_id`),
    DROP COLUMN `row_id`;

-- Tier price
ALTER TABLE `catalog_product_entity_tier_price`
    DROP FOREIGN KEY `CAT_PRD_ENTT_TIER_PRICE_ROW_ID_CAT_PRD_ENTT_ROW_ID`;
ALTER TABLE `catalog_product_entity_tier_price`
    DROP INDEX `UNQ_EBC6A54F44DFA66FA9024CAD97FED6C7`,
    ADD CONSTRAINT `UNQ_EBC6A54F44DFA66FA9024CAD97FED6C7cre` UNIQUE KEY (`entity_id`,`all_groups`,`customer_group_id`,`qty`,`website_id`),
    DROP COLUMN `row_id`;

ALTER TABLE catalog_product_entity_tier_price_store DROP FOREIGN KEY CAT_PRD_ENTT_TIER_PRICE_STORE_ROW_ID_CAT_PRD_ENTT_ROW_ID;

-- Entity
SET FOREIGN_KEY_CHECKS = 0; # Many third party modules refers to the `entity_id` column, we prevent blocking.
ALTER TABLE bss_giftcard_amount_stores DROP FOREIGN KEY BSS_GIFTCARD_AMOUNT_STORES_ROW_ID_CATALOG_PRODUCT_ENTITY_ROW_ID;
ALTER TABLE `catalog_product_entity`
    DROP INDEX `CATALOG_PRODUCT_ENTITY_ENTITY_ID_CREATED_IN_updated_in`,
    DROP FOREIGN KEY `CATALOG_PRODUCT_ENTITY_ENTITY_ID_SEQUENCE_PRODUCT_SEQUENCE_VALUE`,
    DROP COLUMN `row_id`,
    DROP COLUMN `created_in`,
    DROP COLUMN `updated_in`,
    MODIFY COLUMN `entity_id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
    ADD PRIMARY KEY (`entity_id`);

ALTER TABLE bss_giftcard_amount_stores ADD CONSTRAINT `BSS_GIFTCARD_AMOUNT_STORES_ROW_ID_CATALOG_PRODUCT_ENTITY_ROW_ID` FOREIGN KEY (`row_id`) REFERENCES `catalog_product_entity` (`entity_id`);
SET FOREIGN_KEY_CHECKS = 1;

-- Foreign keys
ALTER TABLE `catalog_product_entity_datetime`
    ADD CONSTRAINT `CAT_PRD_ENTT_DTIME_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `catalog_product_entity_decimal`
    ADD CONSTRAINT `CAT_PRD_ENTT_DEC_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `catalog_product_entity_int`
    ADD CONSTRAINT `CAT_PRD_ENTT_INT_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `catalog_product_entity_text`
    ADD CONSTRAINT `CAT_PRD_ENTT_TEXT_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `catalog_product_entity_varchar`
    ADD CONSTRAINT `CAT_PRD_ENTT_VCHR_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `catalog_product_entity_gallery`
    ADD CONSTRAINT `CAT_PRD_ENTT_GLR_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `catalog_product_entity_media_gallery_value`
    ADD CONSTRAINT `CAT_PRD_ENTT_MDA_GLR_VAL_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `catalog_product_entity_media_gallery_value_to_entity`
    ADD CONSTRAINT `CAT_PRD_ENTT_MDA_GLR_VAL_TO_ENTT_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `catalog_product_entity_tier_price`
    ADD CONSTRAINT `CAT_PRD_ENTT_TIER_PRICE_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `catalog_product_bundle_option`
    ADD CONSTRAINT `CAT_PRD_BNDL_OPT_PARENT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`parent_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `catalog_product_bundle_selection`
    ADD CONSTRAINT `CAT_PRD_BNDL_SELECTION_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `downloadable_link`
    ADD CONSTRAINT `DOWNLOADABLE_LINK_PRODUCT_ID_CATALOG_PRODUCT_ENTITY_ENTITY_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `downloadable_sample`
    ADD CONSTRAINT `DOWNLOADABLE_SAMPLE_PRODUCT_ID_CATALOG_PRODUCT_ENTITY_ENTITY_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
DELETE FROM `catalog_product_link` WHERE `linked_product_id` NOT IN (SELECT `entity_id` FROM `catalog_product_entity`);
ALTER TABLE `catalog_product_link`
    ADD CONSTRAINT `CATALOG_PRODUCT_LINK_PRODUCT_ID_CATALOG_PRODUCT_ENTITY_ENTITY_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
    ADD CONSTRAINT `CAT_PRD_LNK_LNKED_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`linked_product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `catalog_product_option`
    ADD CONSTRAINT `CAT_PRD_OPT_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `catalog_product_relation`
    ADD CONSTRAINT `CAT_PRD_RELATION_CHILD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`child_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
    ADD CONSTRAINT `CAT_PRD_RELATION_PARENT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`parent_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `catalog_product_super_attribute`
    ADD CONSTRAINT `CAT_PRD_SPR_ATTR_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `catalog_product_super_link`
    ADD CONSTRAINT `CAT_PRD_SPR_LNK_PARENT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`parent_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
    ADD CONSTRAINT `CAT_PRD_SPR_LNK_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

-- ----------------
-- Drop sequence --
-- ----------------
DELETE FROM `catalog_category_product` WHERE `product_id` NOT IN (SELECT `entity_id` FROM `catalog_product_entity`);
ALTER TABLE `catalog_category_product`
    DROP FOREIGN KEY `CAT_CTGR_PRD_PRD_ID_SEQUENCE_PRD_SEQUENCE_VAL`,
    ADD CONSTRAINT `CAT_CTGR_PRD_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `catalog_compare_item`
    DROP FOREIGN KEY `CATALOG_COMPARE_ITEM_PRODUCT_ID_SEQUENCE_PRODUCT_SEQUENCE_VALUE`,
    ADD CONSTRAINT `CATALOG_COMPARE_ITEM_PRODUCT_ID_CATALOG_PRODUCT_ENTITY_ENTITY_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `catalog_product_bundle_price_index`
    DROP FOREIGN KEY `CAT_PRD_BNDL_PRICE_IDX_ENTT_ID_SEQUENCE_PRD_SEQUENCE_VAL`,
    ADD CONSTRAINT `CAT_PRD_BNDL_PRICE_IDX_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `catalog_product_index_tier_price`
    DROP FOREIGN KEY `CAT_PRD_IDX_TIER_PRICE_ENTT_ID_SEQUENCE_PRD_SEQUENCE_VAL`,
    ADD CONSTRAINT `CAT_PRD_IDX_TIER_PRICE_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `catalog_product_entity_tier_price_store`
    ADD CONSTRAINT `CAT_PRD_ENTT_TIER_PRICE_STORE_ROW_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`row_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

DELETE FROM `catalog_product_website` WHERE `product_id` NOT IN (SELECT `entity_id` FROM `catalog_product_entity`);
ALTER TABLE `catalog_product_website`
    DROP FOREIGN KEY `CAT_PRD_WS_PRD_ID_SEQUENCE_PRD_SEQUENCE_VAL`,
    ADD CONSTRAINT `CAT_PRD_WS_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `catalog_url_rewrite_product_category`
    DROP FOREIGN KEY `CAT_URL_REWRITE_PRD_CTGR_PRD_ID_SEQUENCE_PRD_SEQUENCE_VAL`,
    ADD CONSTRAINT `CAT_URL_REWRITE_PRD_CTGR_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

DELETE FROM `cataloginventory_stock_item` WHERE `product_id` NOT IN (SELECT `entity_id` FROM `catalog_product_entity`);
ALTER TABLE `cataloginventory_stock_item`
    DROP FOREIGN KEY `CATINV_STOCK_ITEM_PRD_ID_SEQUENCE_PRD_SEQUENCE_VAL`,
    ADD CONSTRAINT `CATINV_STOCK_ITEM_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `product_alert_price`
    DROP FOREIGN KEY `PRODUCT_ALERT_PRICE_PRODUCT_ID_SEQUENCE_PRODUCT_SEQUENCE_VALUE`,
    ADD CONSTRAINT `PRODUCT_ALERT_PRICE_PRODUCT_ID_CATALOG_PRODUCT_ENTITY_ENTITY_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `product_alert_stock`
    DROP FOREIGN KEY `PRODUCT_ALERT_STOCK_PRODUCT_ID_SEQUENCE_PRODUCT_SEQUENCE_VALUE`,
    ADD CONSTRAINT `PRODUCT_ALERT_STOCK_PRODUCT_ID_CATALOG_PRODUCT_ENTITY_ENTITY_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `report_compared_product_index`
    DROP FOREIGN KEY `REPORT_CMPD_PRD_IDX_PRD_ID_SEQUENCE_PRD_SEQUENCE_VAL`,
    ADD CONSTRAINT `REPORT_CMPD_PRD_IDX_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `report_viewed_product_aggregated_daily`
    DROP FOREIGN KEY `REPORT_VIEWED_PRD_AGGRED_DAILY_PRD_ID_SEQUENCE_PRD_SEQUENCE_VAL`,
    ADD CONSTRAINT `REPORT_VIEWED_PRD_AGGRED_DAILY_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `report_viewed_product_aggregated_monthly`
    DROP FOREIGN KEY `FK_0140003A30AFC1A9188D723C4634BA5D`,
    ADD CONSTRAINT `REPORT_VIEWED_PRD_AGGRED_MONTHLY_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `report_viewed_product_aggregated_yearly`
    DROP FOREIGN KEY `REPORT_VIEWED_PRD_AGGRED_YEARLY_PRD_ID_SEQUENCE_PRD_SEQUENCE_VAL`,
    ADD CONSTRAINT `REPORT_VIEWED_PRD_AGGRED_YEARLY_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `report_viewed_product_index`
    DROP FOREIGN KEY `REPORT_VIEWED_PRD_IDX_PRD_ID_SEQUENCE_PRD_SEQUENCE_VAL`,
    ADD CONSTRAINT `REPORT_VIEWED_PRD_IDX_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `weee_tax`
    DROP FOREIGN KEY `WEEE_TAX_ENTITY_ID_SEQUENCE_PRODUCT_SEQUENCE_VALUE`,
    ADD CONSTRAINT `WEEE_TAX_ENTITY_ID_CATALOG_PRODUCT_ENTITY_ENTITY_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `wishlist_item`
    DROP FOREIGN KEY `WISHLIST_ITEM_PRODUCT_ID_SEQUENCE_PRODUCT_SEQUENCE_VALUE`,
    ADD CONSTRAINT `WISHLIST_ITEM_PRODUCT_ID_CATALOG_PRODUCT_ENTITY_ENTITY_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

DROP TABLE `sequence_product_bundle_selection`,`sequence_product_bundle_option`,`sequence_product`;

-- Remove EE attributes

DELETE
FROM `eav_entity_type`
WHERE `entity_type_code` IN ('rma_item','cms_page','cms_block');

DELETE
FROM `eav_attribute`
WHERE `attribute_code` IN (
                           'reward_update_notification',
                           'reward_warning_notification',
                           'automatic_sorting',
                           'allow_message',
                           'allow_open_amount',
                           'email_template',
                           'giftcard_amounts',
                           'giftcard_type',
                           'gift_wrapping_available',
                           'gift_wrapping_price',
                           'is_redeemable',
                           'is_returnable',
                           'lifetime',
                           'open_amount_max',
                           'open_amount_min',
                           'related_tgtr_position_behavior',
                           'related_tgtr_position_limit',
                           'upsell_tgtr_position_behavior',
                           'upsell_tgtr_position_limit',
                           'use_config_allow_message',
                           'use_config_email_template',
                           'use_config_is_redeemable',
                           'use_config_lifetime',
                           'reward_points_balance_refunded',
                           'reward_salesrule_points',
                           'condition',
                           'is_qty_decimal',
                           'order_item_id',
                           'product_admin_name',
                           'product_admin_sku',
                           'product_name',
                           'product_options',
                           'product_sku',
                           'qty_approved',
                           'qty_authorized',
                           'qty_requested',
                           'qty_returned',
                           'reason',
                           'reason_other',
                           'resolution',
                           'rma_entity_id'
    );

DROP TABLE IF EXISTS
    `magento_banner_salesrule`,
    `magento_reward_salesrule`,
    `magento_salesrule_filter`,
    `magento_reminder_rule_coupon`,
    `magento_reminder_rule_website`,
    `magento_reminder_template`,
    `magento_reminder_rule_log`,
    `magento_reminder_rule`;

-- Enable `rule_id` column for salesrule

ALTER TABLE `salesrule_customer_group`
    ADD COLUMN `rule_id` INT(10) UNSIGNED NOT NULL COMMENT 'Rule ID';
ALTER TABLE `salesrule_website`
    ADD COLUMN `rule_id` INT(10) UNSIGNED NOT NULL COMMENT 'Rule ID';
ALTER TABLE `salesrule_product_attribute`
    ADD COLUMN `rule_id` INT(10) UNSIGNED NOT NULL COMMENT 'Rule ID';

-- Clean duplicates for salesrule

DELETE e
FROM `salesrule` e
         LEFT OUTER JOIN (
    SELECT MAX(`updated_in`) as `last_updated_in`,`rule_id`
    FROM `salesrule`
    GROUP BY `rule_id`
) AS p
                         ON e.`rule_id` = p.`rule_id` AND e.`updated_in` = p.`last_updated_in`
WHERE p.`last_updated_in` IS NULL;

SET FOREIGN_KEY_CHECKS = 0;
-- Populate `rule_id` column for salesrule
UPDATE salesrule_customer_group SET rule_id = row_id;
UPDATE salesrule_website SET rule_id = row_id;
UPDATE salesrule_product_attribute SET rule_id = row_id;
UPDATE salesrule SET rule_id = row_id;
UPDATE `salesrule_customer_group` v INNER JOIN `salesrule` e ON v.`row_id` = e.`row_id`
SET v.`rule_id` = e.`rule_id`
WHERE 1;
UPDATE `salesrule_website` v INNER JOIN `salesrule` e ON v.`row_id` = e.`row_id`
SET v.`rule_id` = e.`rule_id`
WHERE 1;
UPDATE `salesrule_product_attribute` v INNER JOIN `salesrule` e ON v.`row_id` = e.`row_id`
SET v.`rule_id` = e.`rule_id`
WHERE 1;

-- -----------------------------------------------------
-- Update the `rule_id` relation link for salesrule --
-- -----------------------------------------------------

-- Customer group
ALTER TABLE `salesrule_customer_group`
    DROP FOREIGN KEY `SALESRULE_CUSTOMER_GROUP_ROW_ID_SALESRULE_ROW_ID`,
    DROP PRIMARY KEY,
    ADD PRIMARY KEY (`rule_id`,`customer_group_id`),
    DROP COLUMN `row_id`;

-- Website
ALTER TABLE `salesrule_website`
    DROP FOREIGN KEY `SALESRULE_WEBSITE_ROW_ID_SALESRULE_ROW_ID`,
    DROP PRIMARY KEY,
    ADD PRIMARY KEY (`rule_id`,`website_id`),
    DROP COLUMN `row_id`;

-- Product Attribute
ALTER TABLE `salesrule_product_attribute`
    DROP FOREIGN KEY `SALESRULE_PRODUCT_ATTRIBUTE_ROW_ID_SALESRULE_ROW_ID`,
    DROP PRIMARY KEY,
    ADD PRIMARY KEY (`rule_id`,`website_id`,`customer_group_id`,`attribute_id`),
    DROP COLUMN `row_id`;

-- Salesrule
ALTER TABLE `salesrule`
    DROP FOREIGN KEY `SALESRULE_RULE_ID_SEQUENCE_SALESRULE_SEQUENCE_VALUE`;
ALTER TABLE `salesrule`
    DROP COLUMN `row_id`,
    DROP COLUMN `created_in`,
    DROP COLUMN `updated_in`,
    ADD PRIMARY KEY (`rule_id`),
    MODIFY COLUMN `rule_id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Entity ID';

-- Foreign keys
ALTER TABLE `salesrule_customer_group`
    ADD CONSTRAINT `SALESRULE_CUSTOMER_GROUP_RULE_ID_SALESRULE_RULE_ID` FOREIGN KEY (`rule_id`) REFERENCES `salesrule` (`rule_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `salesrule_website`
    ADD CONSTRAINT `SALESRULE_WEBSITE_RULE_ID_SALESRULE_RULE_ID` FOREIGN KEY (`rule_id`) REFERENCES `salesrule` (`rule_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `salesrule_product_attribute`
    ADD CONSTRAINT `SALESRULE_PRODUCT_ATTRIBUTE_RULE_ID_SALESRULE_RULE_ID` FOREIGN KEY (`rule_id`) REFERENCES `salesrule` (`rule_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

-- ----------------
-- Drop sequence --
-- ----------------

ALTER TABLE `salesrule_coupon`
    DROP FOREIGN KEY `SALESRULE_COUPON_RULE_ID_SEQUENCE_SALESRULE_SEQUENCE_VALUE`,
    ADD CONSTRAINT `SALESRULE_COUPON_RULE_ID_SALESRULE_RULE_ID` FOREIGN KEY (`rule_id`) REFERENCES `salesrule` (`rule_id`);
ALTER TABLE `salesrule_customer`
    DROP FOREIGN KEY `SALESRULE_CUSTOMER_RULE_ID_SEQUENCE_SALESRULE_SEQUENCE_VALUE`,
    ADD CONSTRAINT `SALESRULE_CUSTOMER_RULE_ID_SALESRULE_RULE_ID` FOREIGN KEY (`rule_id`) REFERENCES `salesrule` (`rule_id`);
ALTER TABLE `salesrule_label`
    DROP FOREIGN KEY `SALESRULE_LABEL_RULE_ID_SEQUENCE_SALESRULE_SEQUENCE_VALUE`,
    ADD CONSTRAINT `SALESRULE_LABEL_RULE_ID_SALESRULE_RULE_ID` FOREIGN KEY (`rule_id`) REFERENCES `salesrule` (`rule_id`);

DROP TABLE `sequence_salesrule`;

-- Enable `rule_id` column for catalogrule

ALTER TABLE `catalogrule_customer_group`
    ADD COLUMN `rule_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Rule ID';
ALTER TABLE `catalogrule_website`
    ADD COLUMN `rule_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Rule ID';

-- Clean duplicates for catalogrule

DELETE e
FROM `catalogrule` e
         LEFT OUTER JOIN (
    SELECT MAX(`updated_in`) as `last_updated_in`, `rule_id`
    FROM `catalogrule`
    GROUP BY `rule_id`
) AS p
                         ON e.`rule_id` = p.`rule_id` AND e.`updated_in` = p.`last_updated_in`
WHERE p.`last_updated_in` IS NULL;

-- Populate `rule_id` column for catalogrule

UPDATE `catalogrule_customer_group` v INNER JOIN `catalogrule` e ON v.`row_id` = e.`row_id`
SET v.`rule_id` = e.`rule_id`
WHERE 1;
UPDATE `catalogrule_website` v INNER JOIN `catalogrule` e ON v.`row_id` = e.`row_id`
SET v.`rule_id` = e.`rule_id`
WHERE 1;

-- -----------------------------------------------------
-- Update the `rule_id` relation link for catalogrule --
-- -----------------------------------------------------

-- Customer group
ALTER TABLE `catalogrule_customer_group`
    DROP FOREIGN KEY `CATALOGRULE_CUSTOMER_GROUP_ROW_ID_CATALOGRULE_ROW_ID`,
    DROP PRIMARY KEY,
    ADD PRIMARY KEY (`rule_id`,`customer_group_id`),
    DROP COLUMN `row_id`;

-- Website
ALTER TABLE `catalogrule_website`
    DROP FOREIGN KEY `CATALOGRULE_WEBSITE_ROW_ID_CATALOGRULE_ROW_ID`,
    DROP PRIMARY KEY,
    ADD PRIMARY KEY (`rule_id`,`website_id`),
    DROP COLUMN `row_id`;

-- Catalogrule
ALTER TABLE `catalogrule`
    DROP FOREIGN KEY `CATALOGRULE_RULE_ID_SEQUENCE_CATALOGRULE_SEQUENCE_VALUE`,
    DROP COLUMN `row_id`,
    DROP COLUMN `created_in`,
    DROP COLUMN `updated_in`,
    ADD PRIMARY KEY (`rule_id`),
    MODIFY COLUMN `rule_id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Entity ID';

-- Foreign keys
ALTER TABLE `catalogrule_customer_group`
    ADD CONSTRAINT `CATALOGRULE_CUSTOMER_GROUP_RULE_ID_CATALOGRULE_RULE_ID` FOREIGN KEY (`rule_id`) REFERENCES `catalogrule` (`rule_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `catalogrule_website`
    ADD CONSTRAINT `CATALOGRULE_WEBSITE_RULE_ID_CATALOGRULE_RULE_ID` FOREIGN KEY (`rule_id`) REFERENCES `catalogrule` (`rule_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

-- ----------------
-- Drop sequence --
-- ----------------

DROP TABLE `sequence_catalogrule`;

-- Enable `entity_id` column for catalog category entity

ALTER TABLE `catalog_category_entity_datetime`
    ADD COLUMN `entity_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Entity ID';
ALTER TABLE `catalog_category_entity_decimal`
    ADD COLUMN `entity_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Entity ID';
ALTER TABLE `catalog_category_entity_int`
    ADD COLUMN `entity_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Entity ID';
ALTER TABLE `catalog_category_entity_text`
    ADD COLUMN `entity_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Entity ID';
ALTER TABLE `catalog_category_entity_varchar`
    ADD COLUMN `entity_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Entity ID';

-- Clean duplicates for catalog category entity

DELETE e
FROM `catalog_product_entity` e
         LEFT OUTER JOIN (
    SELECT MAX(`updated_at`) as `last_updated_at`, `entity_id`
    FROM `catalog_product_entity`
    GROUP BY `entity_id`
) AS p
                         ON e.`entity_id` = p.`entity_id` AND e.`updated_at` = p.`last_updated_at`
WHERE p.`last_updated_at` IS NULL;

-- Populate `entity_id` column for catalog category entity

UPDATE `catalog_category_entity_datetime` v INNER JOIN `catalog_category_entity` e ON v.`row_id` = e.`row_id`
SET v.`entity_id` = e.`entity_id`
WHERE 1;
UPDATE `catalog_category_entity_decimal` v INNER JOIN `catalog_category_entity` e ON v.`row_id` = e.`row_id`
SET v.`entity_id` = e.`entity_id`
WHERE 1;
UPDATE `catalog_category_entity_int` v INNER JOIN `catalog_category_entity` e ON v.`row_id` = e.`row_id`
SET v.`entity_id` = e.`entity_id`
WHERE 1;
UPDATE `catalog_category_entity_text` v INNER JOIN `catalog_category_entity` e ON v.`row_id` = e.`row_id`
SET v.`entity_id` = e.`entity_id`
WHERE 1;
UPDATE `catalog_category_entity_varchar` v INNER JOIN `catalog_category_entity` e ON v.`row_id` = e.`row_id`
SET v.`entity_id` = e.`entity_id`
WHERE 1;

-- ------------------------------------------------------------------
-- Update the `entity_id` relation link for catalog product entity --
-- ------------------------------------------------------------------

-- Datetime
ALTER TABLE `catalog_category_entity_datetime`
    DROP FOREIGN KEY `CAT_CTGR_ENTT_DTIME_ROW_ID_CAT_CTGR_ENTT_ROW_ID`,
    DROP INDEX `CATALOG_CATEGORY_ENTITY_DATETIME_ROW_ID_ATTRIBUTE_ID_STORE_ID`,
    ADD CONSTRAINT `CATALOG_CATEGORY_ENTITY_DATETIME_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` UNIQUE KEY (`entity_id`,`attribute_id`,`store_id`),
    DROP COLUMN `row_id`;

-- Decimal
ALTER TABLE `catalog_category_entity_decimal`
    DROP FOREIGN KEY `CAT_CTGR_ENTT_DEC_ROW_ID_CAT_CTGR_ENTT_ROW_ID`,
    DROP INDEX `CATALOG_CATEGORY_ENTITY_DECIMAL_ROW_ID_ATTRIBUTE_ID_STORE_ID`,
    ADD CONSTRAINT `CATALOG_CATEGORY_ENTITY_DECIMAL_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` UNIQUE KEY (`entity_id`,`attribute_id`,`store_id`),
    DROP COLUMN `row_id`;

-- Int
ALTER TABLE `catalog_category_entity_int`
    DROP FOREIGN KEY `CAT_CTGR_ENTT_INT_ROW_ID_CAT_CTGR_ENTT_ROW_ID`,
    DROP INDEX `CATALOG_CATEGORY_ENTITY_INT_ROW_ID_ATTRIBUTE_ID_STORE_ID`,
    ADD CONSTRAINT `CATALOG_CATEGORY_ENTITY_INT_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` UNIQUE KEY (`entity_id`,`attribute_id`,`store_id`),
    DROP COLUMN `row_id`;

-- Text
ALTER TABLE `catalog_category_entity_text`
    DROP FOREIGN KEY `CAT_CTGR_ENTT_TEXT_ROW_ID_CAT_CTGR_ENTT_ROW_ID`,
    DROP INDEX `CATALOG_CATEGORY_ENTITY_TEXT_ROW_ID_ATTRIBUTE_ID_STORE_ID`,
    ADD CONSTRAINT `CATALOG_CATEGORY_ENTITY_TEXT_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` UNIQUE KEY (`entity_id`,`attribute_id`,`store_id`),
    DROP COLUMN `row_id`;

-- Varchar
ALTER TABLE `catalog_category_entity_varchar`
    DROP FOREIGN KEY `CAT_CTGR_ENTT_VCHR_ROW_ID_CAT_CTGR_ENTT_ROW_ID`,
    DROP INDEX `CATALOG_CATEGORY_ENTITY_VARCHAR_ROW_ID_ATTRIBUTE_ID_STORE_ID`,
    ADD CONSTRAINT `CATALOG_CATEGORY_ENTITY_VARCHAR_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` UNIQUE KEY (`entity_id`,`attribute_id`,`store_id`),
    DROP COLUMN `row_id`;

-- Entity
ALTER TABLE `catalog_category_entity`
    DROP FOREIGN KEY `CAT_CTGR_ENTT_ENTT_ID_SEQUENCE_CAT_CTGR_SEQUENCE_VAL`,
    DROP COLUMN `row_id`,
    DROP COLUMN `created_in`,
    DROP COLUMN `updated_in`,
    MODIFY COLUMN `entity_id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
    ADD PRIMARY KEY (`entity_id`);

-- Foreign keys
ALTER TABLE `catalog_category_entity_datetime`
    ADD CONSTRAINT `CAT_CTGR_ENTT_DTIME_ROW_ID_CAT_CTGR_ENTT_ROW_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_category_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `catalog_category_entity_decimal`
    ADD CONSTRAINT `CAT_CTGR_ENTT_DEC_ROW_ID_CAT_CTGR_ENTT_ROW_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_category_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `catalog_category_entity_int`
    ADD CONSTRAINT `CAT_CTGR_ENTT_INT_ROW_ID_CAT_CTGR_ENTT_ROW_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_category_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `catalog_category_entity_text`
    ADD CONSTRAINT `CAT_CTGR_ENTT_TEXT_ROW_ID_CAT_CTGR_ENTT_ROW_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_category_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `catalog_category_entity_varchar`
    ADD CONSTRAINT `CAT_CTGR_ENTT_VCHR_ROW_ID_CAT_CTGR_ENTT_ROW_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_category_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

-- ----------------
-- Drop sequence --
-- ----------------

ALTER TABLE `catalog_category_product`
    DROP FOREIGN KEY `CAT_CTGR_PRD_CTGR_ID_SEQUENCE_CAT_CTGR_SEQUENCE_VAL`,
    ADD CONSTRAINT `CAT_CTGR_PRD_CTGR_ID_CAT_CTGR_ENTT_ENTT_ID` FOREIGN KEY (`category_id`) REFERENCES `catalog_category_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

ALTER TABLE `catalog_url_rewrite_product_category`
    DROP FOREIGN KEY `CAT_URL_REWRITE_PRD_CTGR_CTGR_ID_SEQUENCE_CAT_CTGR_SEQUENCE_VAL`,
    ADD CONSTRAINT `CAT_URL_REWRITE_PRD_CTGR_CTGR_ID_CAT_CTGR_ENTT_ENTT_ID` FOREIGN KEY (`category_id`) REFERENCES `catalog_category_entity` (`entity_id`) ON DELETE CASCADE ON UPDATE RESTRICT;

DROP TABLE `sequence_catalog_category`;

ALTER TABLE `catalog_product_entity_media_gallery_value` DROP INDEX `CAT_PRD_ENTT_MDA_GLR_VAL_ENTT_ID_VAL_ID_STORE_ID`;
ALTER TABLE `wishlist` DROP FOREIGN KEY `WISHLIST_CUSTOMER_ID_CUSTOMER_ENTITY_ENTITY_ID`, DROP INDEX `WISHLIST_CUSTOMER_ID`;
ALTER TABLE `catalog_product_entity_tier_price_store` CHANGE `row_id` `entity_id` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'catalog product row id';
