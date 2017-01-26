# INSTRUCTIONS

# The goal of this exercise is to simulate the creation of a report, by merging two datasets together, and drawing some basic insights. Given the stated assumptions, please provide your answers to the following 4 questions, as well as your code. Use of python, particularly with Pandas, is encouraged.

# Source1.csv:
# Each “campaign” contains three elements, separated by the delimiter “_”. The first element represents an initiative, the second represents an audience, and third represents an asset.
# “A_B_C” means the initiative is A, the audience is B, and the asset is C
# Each “actions” value contains a list of dictionaries, where each element has an action and a type. For example {"x": 63, "action": "like"} means that there were 63 likes of type x.

# Source2.csv
# Each “campaign” contains the same three elements (initiative, audience, asset), separated by the same delimiter “_”, but in this case the order of the elements is random.

# Assumptions:
# A “campaign” is a unique combination of Initiative, Asset and Audience
# CPM = spend/impressions*1000
# CPV = spend/views ONLY for campaigns with an object_type of video. Ignore spend and views for all other object_types in calculating CPV.
# All campaigns are represented for each day in source1.csv
# There may be missing or duplicate campaigns in source2.csv
# For all questions, ignore actions that aren’t of type X or Y.

# Questions:
# How many unique campaigns ran in February?
# What is the total number of conversions on plants?
# What audience, asset combination had the least expensive conversions?
# What was the total cost per video view?


require 'ruby'
require 'rails'
require 'csv'
require 'json'

def unique_campaigns_feb
  @csv_text = CSV.read('source1.csv')
  count = 0
  @all_feb =[]
  @unique_feb =[]

  @csv_text.each do |row|
    #move all february campaigns into hash
    if row[1].split('-')[1] == '02'
      @all_feb << row
    end
  end

  @all_feb.each do |row|
    if @unique_feb.empty?
      @unique_feb << row
    end
    if row[0] != @unique_feb[count][0]
      #count each element and make sure they are unique
      @unique_feb << row
      count+=1
    end
  end

  @february_count = count

  puts @february_count.to_s + ' Unique Campaigns ran in February'

end

def total_plant_conversions
  @csv_text = CSV.read('source1.csv', { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})

  @hashed_data = @csv_text.map { |d| d.to_hash }
  @plants_conversions = 0
  @plants_array = []

  @hashed_data.each do |row|
    #grab all plants intiative and push to array
    if row[:campaign].split('_')[0] == 'plants'
      #parse json, eval wasnt working in  console and its dangerous
      @plants_array << JSON.parse(row[:actions].gsub(':"','=>'))
    end
  end

  @plants_array.each do |row|
    row.each do |ele|
      if ele["action"] == "conversions"
        #grab all keys in each hash action and grab value of said variable
        ele_keys = ele.keys

        ele_keys.delete("action")
        #ignore all other keys only x and y
        if ele_keys == (["x"] || ["y"])
          @plants_conversions = @plants_conversions + ele[ele_keys[0]].to_i
        end
      end
    end
  end

  puts @plants_conversions.to_s + ' is the Total number of Conversions on Plants'
end

def least_audience_asset

  @csv_text = CSV.read('source1.csv')

  @unique_campaigns_hash = {}

  @csv_text.each do |row|
    #intialize
    if @unique_campaigns_hash.empty?
      @unique_campaigns_hash[row[0]] = 0;
      #fake values due to sort_by not working with NaN
      row[2] = 20.0;
      row[3] = 20.0;
     else
    #audience asset combo
      row[0] = row[0].split('_')
      row[0] = [ row[0][1],row[0][2] ].join('_')
    end

    #calculates and adds spend and impressions
    if @unique_campaigns_hash.key?(row[0])
      @unique_campaigns_hash[row[0]] += (( row[2].to_f/row[3].to_f ) * 1000.0)
    else
      @unique_campaigns_hash[row[0]] =  (( row[2].to_f/row[3].to_f ) * 1000.0);
    end
  end

  #sort hash by number
  @unique_campaigns_hash = @unique_campaigns_hash.sort_by { |k,v| v }

  #index value is header
  puts @unique_campaigns_hash[1][0] + ' has the least expensive conversions'

end

def total_cost_per_video_view
  @csv_text1 = CSV.read('source1.csv')
  @csv_text2 = CSV.read('source2.csv')

  @total_cost = 0.to_f;
  @video_hash = {}

  @csv_text2.each do |row|
  #create video has with source2.csv
    if row[1] == 'video'
      #name and CPV value intialized at 0 with video type
      @video_hash[row[0]] = [CPV: 0.0, type:'video'];
    end
  end

  @csv_text1.each do  |row|
  #compare video hash with source1.csv
    if @video_hash.key?(row[0])

      #grab spend from row and intialize views
      spend = row[2].to_f;
      views = 0;

      #parse json, eval wasnt working in  console and its dangerous
      action_array = JSON.parse(row[4].gsub(':"','=>'))

      action_array.each do |ele|
        if ele["action"] == "views"
        #grab all keys in each hash action and grab value of said variable
          ele_keys = ele.keys
          ele_keys.delete("action")
          #ignore all other keys only x and y
          if ele_keys == (["x"] || ["y"])
            #add views iterating through each action
            views = views + ele[ele_keys[0]].to_i
            #calculate CPV and increment to hash
            @video_hash[row[0]][0][:CPV] += spend/views
          end
        end
      end
    @total_cost += @video_hash[row[0]][0][:CPV].to_f
    end
  end

  puts @total_cost.to_s + ' is the total cost per video view'

end

unique_campaigns_feb
total_plant_conversions
least_audience_asset
total_cost_per_video_view
