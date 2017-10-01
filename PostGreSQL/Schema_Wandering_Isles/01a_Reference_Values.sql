INSERT INTO wandering_isles.scale
    (scale)
VALUES
    ('Detail')
  , ('Region')
  , ('County')
  , ('Country');

INSERT INTO wandering_isles.make
    (make, description)
VALUES
    ('Mortal', 'Features constructed by mortal races.')
  , ('Natural', 'Features that are not man-made. May be man altered.')
  , ('Divine', 'Feature created by some devine source.');

INSERT INTO wandering_isles.class_primary
    (class_primary, description)
VALUES
    ('Building', 'Buildings (with & without walls).')
  , ('Structure', 'Manmade features other than buildings.')
  , ('Road', 'Path with additional strucuture.')
  , ('Track', 'Path with no purpose-built structures.')
  , ('Landform', 'Areas of notable landforms (e.g. cliffs, rock exposures.')
  , ('Water (Tidal)', 'Areas of water with major tidal influence.')
  , ('Water (Inland)', 'Areas of water without major tidal influence.')
  , ('Farmland', 'Area that is actively farmed for food.')
  , ('Natural Environment', 'Areas of natural environments.')
  , ('Built Environment', 'Areas of man-made environments.')
  , ('Historic', 'Features that were built in a previous time and are generally not used any more.');

INSERT INTO wandering_isles.class_secondary
    (class_secondary, description)
VALUES
    ('None', 'No notable secondary classes.')
  , ('Beach', NULL)
  , ('Bridge', NULL)
  , ('Crops', NULL)
  , ('Cliff', NULL)
  , ('Cliff (Top)', NULL)
  , ('Cliff (Bottom)', NULL)
  , ('Garden', NULL)
  , ('Road (Major)', NULL)
  , ('Orchard', NULL)
  , ('Rock Outcrop', NULL)
  , ('Ruins', NULL)
  , ('Scree', NULL)
  , ('Tomb', NULL)
  , ('Trees (Coniferous)', NULL)
  , ('Trees (Nonconiferous)', NULL)
  , ('Wall', NULL);

INSERT INTO wandering_isles.material
    (material, description)
VALUES
    ('Undefined', 'The materical isn''t defined for this feature.')
  , ('Wood', NULL)
  , ('Bare Soil', NULL)
  , ('Grass', NULL)
  , ('Sand', NULL)
  , ('Stone', NULL);

INSERT INTO wandering_isles.feature_purpose
    (feature_purpose, abbreviation)
VALUES
    ('Dwelling', 'DWL')
  , ('Blacksmith', 'BSMITH')
  , ('Temple', 'TMPL')
  , ('Barracks', 'BRRKS')
  , ('Watch Tower', 'WTCH')
  , ('Shipwright', 'SWRT')
  , ('Harbourmaster', 'HMTR')
  , ('Guard Post', 'GPST')
  , ('Jail', 'JL')
  , ('Tavern', 'TVRN')
  , ('Doctors', 'DCTR')
  , ('Merchant', 'MRCH')
  , ('Warehouse', 'WRHS')
  , ('Town Hall', 'TNHLL')
  , ('Wizard''s Tower', 'WZD')
  , ('Stables', 'STBL')
  , ('Storage', 'STRG');

INSERT INTO wandering_isles.transport_type
    (transport_type)
VALUES
    ('Regional Road')
  , ('Local Road')
  , ('Track')
  , ('Minor Track');

