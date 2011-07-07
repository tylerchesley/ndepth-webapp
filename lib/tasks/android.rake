require 'csv'
require 'rake/clean'

COL_SEP = "^"

# select CONCAT("""", nutr_no, """ => """, LOWER(tagname), """, #", nutr_desc) from nutrient_definitions WHERE tagname = "" order by sr_order;
NUTR_NO_TO_TAGNAME = {
  "257" => "PROCNT_ADJ", #Adjusted Protein
  "578" => "VITB12_ADD", #Vitamin B-12, added
  "573" => "TOCPH_ADD", #Vitamin E, added
  "338" => "LUT_ZEA",
  "324" => "VITD_IU", # Temporary
  "676" => "", #22:1 c
  "664" => "", #22:1 t
  "666" => "", #18:2 i
  "665" => "", #18:2 t not further defined
  "856" => "" #18:3i
}

# select CONCAT("""", nutr_no, """ => """, UPPER(nutr_desc), """,") from nutrient_definitions order by sr_order;
NUTR_NO_TO_COLUMN_NAME = {
  "255" => "WATER",
  "208" => "ENERGY_KCAL",
  "268" => "ENERGY_KJ",
  "203" => "PROTEIN",
  "257" => "PROTEIN_ADJUSTED",
  "204" => "LIPID_TOTAL",
  "207" => "ASH",
  "205" => "CARBOHYDRATE",
  "291" => "FIBER_TOTAL",
  "269" => "SUGARS_TOTAL",
  "210" => "SUCROSE",
  "211" => "GLUCOSE",
  "212" => "FRUCTOSE",
  "213" => "LACTOSE",
  "214" => "MALTOSE",
  "287" => "GALACTOSE",
  "209" => "STARCH",
  "301" => "CALCIUM",
  "303" => "IRON",
  "304" => "MAGNESIUM",
  "305" => "PHOSPHORUS",
  "306" => "POTASSIUM",
  "307" => "SODIUM",
  "309" => "ZINC",
  "312" => "COPPER",
  "315" => "MANGANESE",
  "317" => "SELENIUM",
  "313" => "FLUORIDE",
  "401" => "VITAMIN_C",
  "404" => "THIAMIN",
  "405" => "RIBOFLAVIN",
  "406" => "NIACIN",
  "410" => "PANTOTHENIC_ACID",
  "415" => "VITAMIN_B6",
  "417" => "FOLATE_TOTAL",
  "431" => "FOLIC_ACID",
  "432" => "FOLATE_FOOD",
  "435" => "FOLATE_DFE",
  "421" => "CHOLINE_TOTAL",
  "454" => "BETAINE",
  "418" => "VITAMIN_B12",
  "578" => "VITAMIN_B12_ADDED",
  "320" => "VITAMIN_A_RAE",
  "319" => "RETINOL",
  "321" => "CAROTENE_BETA",
  "322" => "CAROTENE_ALPHA",
  "334" => "CRYPTOXANTHIN_BETA",
  "318" => "VITAMIN_A_IU",
  "337" => "LYCOPENE",
  "338" => "LUTEIN_ZEAXANTHIN",
  "323" => "TOCOPHEROL_ALPHA",
  "573" => "TOCOPHEROL_ADDED",
  "341" => "TOCOPHEROL_BETA",
  "342" => "TOCOPHEROL_GAMMA",
  "343" => "TOCOPHEROL_DELTA",
  "328" => "VITAMIN_D",
  "325" => "VITAMIN_D2",
  "326" => "VITAMIN_D3",
  "324" => "VITAMIN_D_IU",
  "430" => "VITAMIN_K",
  "429" => "DIHYDROPHYLLOQUINONE",
  "428" => "MENAQUINONE_4",
  "606" => "FAT_SATURATED_TOTAL",
  "607" => "4:0",
  "608" => "6:0",
  "609" => "8:0",
  "610" => "10:0",
  "611" => "12:0",
  "696" => "13:0",
  "612" => "14:0",
  "652" => "15:0",
  "613" => "16:0",
  "653" => "17:0",
  "614" => "18:0",
  "615" => "20:0",
  "624" => "22:0",
  "654" => "24:0",
  "645" => "FAT_MONOUNSATURATED_TOTAL",
  "625" => "14:1",
  "697" => "15:1",
  "626" => "16:1 UNDIFFERENTIATED",
  "673" => "16:1 C",
  "662" => "16:1 T",
  "687" => "17:1",
  "617" => "18:1 UNDIFFERENTIATED",
  "674" => "18:1 C",
  "663" => "18:1 T",
  "859" => "18:1-11T (18:1T N-7)",
  "628" => "20:1",
  "630" => "22:1 UNDIFFERENTIATED",
  "676" => "22:1 C",
  "664" => "22:1 T",
  "671" => "24:1 C",
  "646" => "FAT_POLYUNSATURATED_TOTAL",
  "618" => "18:2 UNDIFFERENTIATED",
  "675" => "18:2 N-6 C,C",
  "670" => "18:2 CLAS",
  "669" => "18:2 T,T",
  "666" => "18:2 I",
  "665" => "18:2 T NOT FURTHER DEFINED",
  "619" => "18:3 UNDIFFERENTIATED",
  "851" => "18:3 N-3 C,C,C (ALA)",
  "685" => "18:3 N-6 C,C,C",
  "856" => "18:3I",
  "627" => "18:4",
  "672" => "20:2 N-6 C,C",
  "689" => "20:3 UNDIFFERENTIATED",
  "852" => "20:3 N-3",
  "853" => "20:3 N-6",
  "620" => "20:4 UNDIFFERENTIATED",
  "855" => "20:4 N-6",
  "629" => "20:5 N-3 (EPA)",
  "857" => "21:5",
  "858" => "22:4",
  "631" => "22:5 N-3 (DPA)",
  "621" => "22:6 N-3 (DHA)",
  "605" => "FAT_TRANS_TOTAL",
  "693" => "FAT_TRANS_MONOENOIC_TOTAL",
  "695" => "FAT_TRANS_POLYENOIC_TOTAL",
  "601" => "CHOLESTEROL",
  "636" => "PHYTOSTEROLS",
  "638" => "STIGMASTEROL",
  "639" => "CAMPESTEROL",
  "641" => "BETA_SITOSTEROL",
  "501" => "TRYPTOPHAN",
  "502" => "THREONINE",
  "503" => "ISOLEUCINE",
  "504" => "LEUCINE",
  "505" => "LYSINE",
  "506" => "METHIONINE",
  "507" => "CYSTINE",
  "508" => "PHENYLALANINE",
  "509" => "TYROSINE",
  "510" => "VALINE",
  "511" => "ARGININE",
  "512" => "HISTIDINE",
  "513" => "ALANINE",
  "514" => "ASPARTIC_ACID",
  "515" => "GLUTAMIC_ACID",
  "516" => "GLYCINE",
  "517" => "PROLINE",
  "518" => "SERINE",
  "521" => "HYDROXYPROLINE",
  "221" => "ALCOHOL",
  "262" => "CAFFEINE",
  "263" => "THEOBROMINE"
}

#select CONCAT("""", nutr_no, """, #", nutr_desc, " ", units, " ", tagname) from nutrient_definitions order by sr_order;
INCLUDED_NUTR_NO = [
  "255", #Water g WATER
  "208", #Energy kcal ENERC_KCAL
#  "268", #Energy kJ ENERC_KJ
  "203", #Protein g PROCNT
#  "257", #Adjusted Protein g 
  "204", #Total lipid (fat) g FAT
  "207", #Ash g ASH
  "205", #Carbohydrate, by difference g CHOCDF
  "291", #Fiber, total dietary g FIBTG
  "269", #Sugars, total g SUGAR
  "210", #Sucrose g SUCS
  "211", #Glucose (dextrose) g GLUS
  "212", #Fructose g FRUS
  "213", #Lactose g LACS
  "214", #Maltose g MALS
  "287", #Galactose g GALS
  "209", #Starch g STARCH
  "301", #Calcium, Ca mg CA
  "303", #Iron, Fe mg FE
  "304", #Magnesium, Mg mg MG
  "305", #Phosphorus, P mg P
  "306", #Potassium, K mg K
  "307", #Sodium, Na mg NA
  "309", #Zinc, Zn mg ZN
  "312", #Copper, Cu mg CU
  "315", #Manganese, Mn mg MN
  "317", #Selenium, Se mcg SE
  "313", #Fluoride, F mcg FLD
  "401", #Vitamin C, total ascorbic acid mg VITC
  "404", #Thiamin mg THIA
  "405", #Riboflavin mg RIBF
  "406", #Niacin mg NIA
  "410", #Pantothenic acid mg PANTAC
  "415", #Vitamin B-6 mg VITB6A
  "417", #Folate, total mcg FOL
  "431", #Folic acid mcg FOLAC
  "432", #Folate, food mcg FOLFD
  "435", #Folate, DFE mcg_DFE FOLDFE
  "421", #Choline, total mg CHOLN
  "454", #Betaine mg BETN
  "418", #Vitamin B-12 mcg VITB12
  "578", #Vitamin B-12, added mcg 
  "320", #Vitamin A, RAE mcg_RAE VITA_RAE
  "319", #Retinol mcg RETOL
  "321", #Carotene, beta mcg CARTB
  "322", #Carotene, alpha mcg CARTA
  "334", #Cryptoxanthin, beta mcg CRYPX
  "318", #Vitamin A, IU IU VITA_IU
  "337", #Lycopene mcg LYCPN
  "338", #Lutein + zeaxanthin mcg LUT+ZEA
  "323", #Vitamin E (alpha-tocopherol) mg TOCPHA
  "573", #Vitamin E, added mg 
  "341", #Tocopherol, beta mg TOCPHB
  "342", #Tocopherol, gamma mg TOCPHG
  "343", #Tocopherol, delta mg TOCPHD
  "328", #Vitamin D (D2 + D3) mcg VITD
  "325", #Vitamin D2 (ergocalciferol) mcg ERGCAL
  "326", #Vitamin D3 (cholecalciferol) mcg CHOCAL
  "324", #Vitamin D IU VITD
  "430", #Vitamin K (phylloquinone) mcg VITK1
  "429", #Dihydrophylloquinone mcg VITK1D
  "428", #Menaquinone-4 mcg MK4
  "606", #Fatty acids, total saturated g FASAT
#  "607", #4:0 g F4D0
#  "608", #6:0 g F6D0
#  "609", #8:0 g F8D0
#  "610", #10:0 g F10D0
#  "611", #12:0 g F12D0
#  "696", #13:0 g F13D0
#  "612", #14:0 g F14D0
#  "652", #15:0 g F15D0
#  "613", #16:0 g F16D0
#  "653", #17:0 g F17D0
#  "614", #18:0 g F18D0
#  "615", #20:0 g F20D0
#  "624", #22:0 g F22D0
#  "654", #24:0 g F24D0
  "645", #Fatty acids, total monounsaturated g FAMS
#  "625", #14:1 g F14D1
#  "697", #15:1 g F15D1
#  "626", #16:1 undifferentiated g F16D1
#  "673", #16:1 c g F16D1C
#  "662", #16:1 t g F16D1T
#  "687", #17:1 g F17D1
#  "617", #18:1 undifferentiated g F18D1
#  "674", #18:1 c g F18D1C
#  "663", #18:1 t g F18D1T
#  "859", #18:1-11t (18:1t n-7) g F18D1TN7
#  "628", #20:1 g F20D1
#  "630", #22:1 undifferentiated g F22D1
#  "676", #22:1 c g 
#  "664", #22:1 t g 
#  "671", #24:1 c g F24D1C
  "646", #Fatty acids, total polyunsaturated g FAPU
#  "618", #18:2 undifferentiated g F18D2
#  "675", #18:2 n-6 c,c g F18D2CN6
#  "670", #18:2 CLAs g F18D2CLA
#  "669", #18:2 t,t g F18D2TT
#  "666", #18:2 i g 
#  "665", #18:2 t not further defined g 
#  "619", #18:3 undifferentiated g F18D3
#  "851", #18:3 n-3 c,c,c (ALA) g F18D3CN3
#  "685", #18:3 n-6 c,c,c g F18D3CN6
#  "856", #18:3i g 
#  "627", #18:4 g F18D4
#  "672", #20:2 n-6 c,c g F20D2CN6
#  "689", #20:3 undifferentiated g F20D3
#  "852", #20:3 n-3 g F20D3N3
#  "853", #20:3 n-6 g F20D3N6
#  "620", #20:4 undifferentiated g F20D4
#  "855", #20:4 n-6 g F20D4N6
#  "629", #20:5 n-3 (EPA) g F20D5
#  "857", #21:5 g F21D5
#  "858", #22:4 g F22D4
#  "631", #22:5 n-3 (DPA) g F22D5
#  "621", #22:6 n-3 (DHA) g F22D6
  "605", #Fatty acids, total trans g FATRN
  "693", #Fatty acids, total trans-monoenoic g FATRNM
  "695", #Fatty acids, total trans-polyenoic g FATRNP
  "601", #Cholesterol mg CHOLE
  "636", #Phytosterols mg PHYSTR
  "638", #Stigmasterol mg STID7
  "639", #Campesterol mg CAMD5
  "641", #Beta-sitosterol mg SITSTR
  "501", #Tryptophan g TRP_G
  "502", #Threonine g THR_G
  "503", #Isoleucine g ILE_G
  "504", #Leucine g LEU_G
  "505", #Lysine g LYS_G
  "506", #Methionine g MET_G
  "507", #Cystine g CYS_G
  "508", #Phenylalanine g PHE_G
  "509", #Tyrosine g TYR_G
  "510", #Valine g VAL_G
  "511", #Arginine g ARG_G
  "512", #Histidine g HISTN_G
  "513", #Alanine g ALA_G
  "514", #Aspartic acid g ASP_G
  "515", #Glutamic acid g GLU_G
  "516", #Glycine g GLY_G
  "517", #Proline g PRO_G
  "518", #Serine g SER_G
  "521", #Hydroxyproline g HYP
  "221", #Alcohol, ethyl g ALC
  "262", #Caffeine mg CAFFN
  "263" #Theobromine mg THEBRN
]

ANDROID_RES_DIR = File.join(NdepthWebapp::Application.config.android_application_dir, "res")
ANDROID_RAW_DIR = File.join(ANDROID_RES_DIR, "raw")
ANDROID_VALUES_DIR = File.join(ANDROID_RES_DIR, "values")
ANDROID_XML_DIR = File.join(ANDROID_RES_DIR, "xml")
TEMP_DIR = "android"

FOODS_PREFIX = "foods"
DRI_PREFIX = "dri"

FOOD_GROUPS_FILENAME = "food_groups.csv"
WEIGHTS_FILENAME = "weights.csv"
NUTRIENTS_FILENAME = "nutrients.xml"
UNITS_FILENAME = "units.xml"

def get_dri_filename(group)
  parts = [DRI_PREFIX, group.gender]
  parts << group.status unless !group.status
  parts << (group.age_min < 1 ? group.age_min : group.age_min.to_i)
  parts << (group.age_max < 1 ? group.age_max : group.age_max.to_i) unless !group.age_max
  "#{parts.join('_')}.xml"
end

def get_nutrient_tagname(definition) 
  NUTR_NO_TO_TAGNAME[definition[:nutr_no].to_s].nil? ? definition[:tagname] : NUTR_NO_TO_TAGNAME[definition[:nutr_no].to_s] 
end

namespace :android do
  
  directory TEMP_DIR
  
  #############################################################################
  ##  Food Groups Tasks
  #############################################################################
  
  task :cleanup_food_groups_file do 
    begin
      rm(File.join(TEMP_DIR, FOOD_GROUPS_FILENAME))
      rm(File.join(ANDROID_RAW_DIR, FOOD_GROUPS_FILENAME))
    rescue
    end
  end
  
  desc "Generates the food groups CSV file for the Android application."
  task :generate_food_groups_file => [:environment] do
    CSV.open(File.join(TEMP_DIR, FOOD_GROUPS_FILENAME), "wb", {:col_sep => COL_SEP, :quote_char => "~"}) do |csv|
      Nutrition::FoodGroup.all.each do |food_group|
        csv << [food_group[:fdgrp_cd], food_group[:fdgrp_desc].chomp]
      end
    end
  end
  
  desc "Copy the generated food groups file to the Android project."
  task :copy_food_groups_file do 
    cp(FileList[File.join(TEMP_DIR, FOOD_GROUPS_FILENAME)], ANDROID_RAW_DIR)
  end
  
  desc "Exports the food groups file to CSV for the android application"
  task :export_food_groups => [TEMP_DIR, :cleanup_food_groups_file, :generate_food_groups_file, :copy_food_groups_file]
  
  #############################################################################
  ##  Weight Tasks
  #############################################################################
  
  task :cleanup_weights_file do 
    begin
      rm(File.join(TEMP_DIR, WEIGHTS_FILENAME))
      rm(File.join(ANDROID_RAW_DIR, WEIGHTS_FILENAME))
    rescue
    end
  end
  
  desc "Generates the weights CSV file for the Android application."
  task :generate_weights_file => [:environment] do
    CSV.open(File.join(TEMP_DIR, WEIGHTS_FILENAME), "wb", {:col_sep => COL_SEP, :quote_char => "~"}) do |csv|
      Nutrition::Weight.all.each do |weight|
        csv << [
          weight[:ndb_no],
          weight[:amount],
          weight[:msre_desc],
          weight[:gm_wgt]
        ]
      end
    end
  end
  
  desc "Copy the generated weights file to the Android project."
  task :copy_weights_file do 
    cp(FileList[File.join(TEMP_DIR, WEIGHTS_FILENAME)], ANDROID_RAW_DIR)
  end
  
  desc "Exports the weights file to CSV for the android application"
  task :export_weights => [TEMP_DIR, :cleanup_weights_file, :generate_weights_file, :copy_weights_file]  
  
  #############################################################################
  ##  Food Tasks
  #############################################################################
  
  task :cleanup_food_files do
    rm(FileList[File.join(TEMP_DIR, "#{FOODS_PREFIX}*")])
    rm(FileList[File.join(ANDROID_RAW_DIR, "#{FOODS_PREFIX}*")])
  end
  
  desc "Generates the food CSV files for the Android application."
  task :generate_food_files => [:environment] do 
    connection = Nutrition::Nutrient.connection
    select_clause = "SELECT nutrients.nutr_no, nutr_val FROM `nutrients` WHERE "
    in_clause = "(nutrients.nutr_no IN (#{INCLUDED_NUTR_NO.join(',')}))" 
    order_clause = " ORDER BY sr_order;"
    CSV.open(File.join(TEMP_DIR, "foods.csv"), "w", {:col_sep => COL_SEP, :quote_char => "~"}) do |csv|
      Nutrition::FoodDescription.all.each do |food|
        data = []
        data << food[:ndb_no]
        data << food[:long_desc]
        data << food[:fdgrp_cd]
        data << food[:pro_factor]
        data << food[:fat_factor]
        data << food[:cho_factor]
        nutrients = {}
        connection.execute("#{select_clause} (`nutrients`.`ndb_no` = '#{food[:ndb_no]}') AND #{in_clause}").each do |n|
          nutrients[n[0]] = n[1]
        end
        INCLUDED_NUTR_NO.each do |nutr_no|
          data << nutrients[nutr_no]
        end
        # Nutrition::NutrientDefinition.joins("LEFT OUTER JOIN nutrients ON nutrients.nutr_no = nutrient_definitions.nutr_no").where(:nutrients => {:ndb_no => food[:ndb_no]}, :nutrient_definitions => {:nutr_no => INCLUDED_NUTR_NO}).order("sr_order").each do |definition|
        #           puts definition.nutrient[:nutr_val].to_s
        #           data << definition.nutrient[:nutr_val]
        #         end
        csv << data
      end
    end
  end
  
  desc "Splits the food file into files lass than one meg in size. Note you must have the corelibs extension installed on OS X"
  task :split_food_files => :environment do 
    system("gsplit -C 975k -a 1 -d foods.csv 'foods_'")
  end
  
  desc "Copy the generated Food files to the Android project."
  task :copy_food_files do 
    cp(FileList[File.join(TEMP_DIR, "#{FOODS_PREFIX}*")], ANDROID_RAW_DIR)
  end
  
  desc "Flattens the nutrition data for easier use and import in the android application."
  task :export_foods => [TEMP_DIR, :cleanup_food_files, :generate_food_files, :split_food_files, :copy_food_files]
  
  #############################################################################
  ##  Dietary Reference Intakes Tasks
  #############################################################################
  
  task :cleanup_dri_files do 
    rm(FileList[File.join(TEMP_DIR, "#{DRI_PREFIX}*")])
    rm(FileList[File.join(ANDROID_XML_DIR, "#{DRI_PREFIX}*")])
  end
  
  desc "Generate the DRI CSV files for the Android project."
  task :generate_dri_files => [:environment] do
    puts "Generating the DRI CSV files for the Android project."
    Nutrition::DietaryReferenceIntakeGroup.all.each do |group|
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.dietary_reference_intakes {
          Nutrition::DietaryReferenceIntake.joins(:nutrient_definition).where(:dietary_reference_intake_group_id => group.id, 
            :nutrient_definitions => {:nutr_no => INCLUDED_NUTR_NO}).each do |dri|
            xml.dietary_reference_intake {
              xml.tagname dri.tagname
              xml.rda     dri.recommended_dietary_allowance
              xml.ai      dri.adequate_intake
              xml.ul      dri.upper_intake_level
            }
          end
        }  
      end
      File.open(File.join(TEMP_DIR, get_dri_filename(group)), "w").write(builder.to_xml)
    end
  end
  
  desc "Copy the exported DRI files to the Android project."
  task :copy_dri_files do
    puts "Copying DRI CSV files to the android project..."
    cp(FileList[File.join(TEMP_DIR, "#{DRI_PREFIX}*")], ANDROID_XML_DIR)
  end
  
  desc "Export Dietary Reference Intakes"
  task :export_dris => [TEMP_DIR, :cleanup_dri_files, :generate_dri_files, :copy_dri_files]
  
  desc "Export nutrition data for android application."
  multitask :export_all => ["android:export_food_groups", "android:export_weights", "android:export_foods", "android:export_dris"] do 
    puts "Finished exporting data"
  end
  
  desc "Generates the columns for the foods table in the android application based on the INCLUDED_NUTR_NO array"
  task :generate_food_nutrients_column_constants => :environment do
    Nutrition::NutrientDefinition.where(:nutr_no => INCLUDED_NUTR_NO).order("sr_order").each do |definition|
      tagname = NUTR_NO_TO_TAGNAME[definition[:nutr_no].to_s] ? NUTR_NO_TO_TAGNAME[definition[:nutr_no].to_s] : definition[:tagname]
      puts "public static final String #{NUTR_NO_TO_COLUMN_NAME[definition[:nutr_no].to_s]} = \"#{tagname.downcase}\";"
      puts ""
    end
  end
  
  desc "Generates the create table colums for the foods table in the android application based on the INCLUDED_NUTR_NO array"
  task :generate_food_nutrients_columns => :environment do
    Nutrition::NutrientDefinition.where(:nutr_no => INCLUDED_NUTR_NO).order("sr_order").each do |definition|
      tagname = definition[:tagname].empty? ? NUTR_NO_TO_TAGNAME[definition[:nutr_no].to_s] : definition[:tagname]
      puts "+ Foods.#{NUTR_NO_TO_COLUMN_NAME[definition[:nutr_no].to_s]} + \" REAL, \""
    end
  end
  
  desc "Generate Nutrients String array."
  task :generate_nutrients_string_array => :environment do
    nutrients = Nutrition::NutrientDefinition.where(:nutr_no => INCLUDED_NUTR_NO).order("sr_order")
    tagnames = nutrients.map{|d| NUTR_NO_TO_COLUMN_NAME[d[:nutr_no]].to_s }
    content_projection = ["_ID", "NDB_NO", "NAME", "PROTEIN_FACTOR", "FAT_FACTOR", "CARBOHYDRATE_FACTOR"].concat(tagnames)
     
    puts "public static final String[] CONTENT_PROJECTION = {"
    puts content_projection.map{|c| "Foods.#{c}" }.join(",\n")
    puts "}"
    
    puts "\n\n"
    
    content_projection.each_index do |i|
      puts "public static final int #{content_projection[i]}_INDEX = #{i};"
    end 
     
    puts "\n\n" 
     
    puts "private static final String[] NUTRIENTS = {"
    puts tagnames.map{|n| "Foods.#{n}" }.join(",\n")
    puts "}"
    
    puts "private static final String[] UNITS = {"
    puts nutrients.map{|n| "\"#{n.units}\"" }.join(",\n")
    puts "}"
    
  end
  
  #############################################################################
  ##  Units String Tasks
  #############################################################################
  
  task :cleanup_units_file do 
    begin
      rm(File.join(TEMP_DIR, UNITS_FILENAME))
      rm(File.join(ANDROID_VALUES_DIR, UNITS_FILENAME))
    rescue
    end 
  end
  
  desc "Generate the weights strings file."
  task :generate_units_file => :environment do
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.resources {
        Nutrition::NutrientDefinition.group("units").each do |u|
          xml.string(:name => "unit_#{u.units.downcase}") {
            xml.text u.units
          }
        end
      }
    end
    File.open(File.join(TEMP_DIR, UNITS_FILENAME), "w").write(builder.to_xml)
  end
  
  desc "Copies the units string file to the Android project."
  task :copy_units_file do
    cp(File.join(TEMP_DIR, UNITS_FILENAME), File.join(ANDROID_VALUES_DIR, UNITS_FILENAME))
  end
  
  desc "Export nutrient names string file to Android project."
  task :export_units_file => [TEMP_DIR, :cleanup_units_file, :generate_units_file, :copy_units_file]
  
  #############################################################################
  ##  Nutrient Names String Tasks
  #############################################################################
  
  task :cleanup_nutrient_names_file do 
    begin
      rm(File.join(TEMP_DIR, NUTRIENTS_FILENAME))
      rm(File.join(ANDROID_VALUES_DIR, NUTRIENTS_FILENAME))
    rescue
    end
  end
  
  desc "Generates the nutrient names string resource file for the Android project."
  task :generate_nutrient_names_file => :environment do 
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.resources {
        Nutrition::NutrientDefinition.where(:nutr_no => INCLUDED_NUTR_NO).order("sr_order").each do |definition|
          xml.string(:name => get_nutrient_tagname(definition).downcase){
            xml.text definition[:nutr_desc]
          } 
        end
      }
    end
    File.open(File.join(TEMP_DIR, NUTRIENTS_FILENAME), "w").write(builder.to_xml)
  end
  
  desc "Copies the nutrient names string file to the Android project."
  task :copy_nutrient_names_file do
    cp(File.join(TEMP_DIR, NUTRIENTS_FILENAME), File.join(ANDROID_VALUES_DIR, NUTRIENTS_FILENAME))
  end
  
  desc "Export nutrient names string file to Android project."
  task :export_nutrient_names_file => [TEMP_DIR, :cleanup_nutrient_names_file, :generate_nutrient_names_file, :copy_nutrient_names_file]
  
end