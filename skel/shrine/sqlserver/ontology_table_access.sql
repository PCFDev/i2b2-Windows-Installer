-- modified to fit Postgres 2014-07-21

-- DELETE potential conflict entry from previous install, just to be safe.
delete from I2B2_DB_SCHEMA.TABLE_ACCESS where C_TABLE_CD = 'SHRINE';

-- Create a new entry in table access allowing this Ontology to be used for project SHRINE
INSERT into I2B2_DB_SCHEMA.TABLE_ACCESS
( C_TABLE_CD,
  C_TABLE_NAME,
  C_PROTECTED_ACCESS,
  C_HLEVEL,
  C_NAME,
  C_FULLNAME,
  C_SYNONYM_CD,
  C_VISUALATTRIBUTES,
  C_TOOLTIP,
  C_FACTTABLECOLUMN,
  C_DIMTABLENAME,
  C_COLUMNNAME,
  C_COLUMNDATATYPE,
  C_DIMCODE,
  C_OPERATOR)
values
( 'SHRINE',
  'SHRINE',
  'N',
   0,
   'SHRINE Ontology',
   '\SHRINE\',
   'N',
   'CA',
   'SHRINE Ontology',
   'concept_cd',
   'concept_dimension',
   'concept_path',
   'T',
   '\SHRINE\',
   'LIKE')
