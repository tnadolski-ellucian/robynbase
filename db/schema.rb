# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150810114536) do

  create_table "COMP", primary_key: "COMPID", force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
    t.string  "Artist",     limit: 64
    t.string  "Title",      limit: 64
    t.float   "Year",       limit: 53
    t.string  "Medium",     limit: 16
    t.string  "MCODE",      limit: 1
    t.string  "Label",      limit: 64
    t.string  "CatNo",      limit: 16
    t.string  "Type",       limit: 16
    t.boolean "Single",                 default: false
    t.string  "Desc",       limit: 64
    t.string  "Comments",   limit: 128
    t.integer "MAJRID",                 default: 0
    t.string  "CoverImage", limit: 32
    t.string  "Field9",     limit: 2
    t.string  "Field11",    limit: 2
    t.index ["Desc"], name: "Desc", using: :btree
    t.index ["MAJRID"], name: "MAJRID", using: :btree
    t.index ["MCODE"], name: "MCODE", using: :btree
    t.index ["Medium"], name: "Medium", using: :btree
    t.index ["Title"], name: "Title", using: :btree
    t.index ["Type"], name: "Type", using: :btree
  end

  create_table "FEG", primary_key: "FEGID", id: :string, limit: 50, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
    t.string "Lastname",  limit: 20
    t.string "Firstname", limit: 20
    t.string "Street",    limit: 35
    t.string "City",      limit: 25
    t.string "State",     limit: 2
    t.string "Zip",       limit: 11
    t.string "Country",   limit: 20
    t.text   "EMail",     limit: 4294967295
    t.text   "URL",       limit: 4294967295
    t.index ["FEGID"], name: "FEGID", unique: true, using: :btree
  end

  create_table "FEGNAME", primary_key: ["FIRST", "LAST"], force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
    t.string "FIRST",   limit: 24,  null: false
    t.string "LAST",    limit: 32,  null: false
    t.string "FEGNAME", limit: 128
  end

  create_table "FEGWORD", primary_key: "WORDID", force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
    t.integer "WORDTYPE",  limit: 1,  default: 0,     null: false
    t.string  "WORDIS",    limit: 32,                 null: false
    t.string  "CONNECTOR", limit: 8
    t.boolean "NICE",                 default: false
    t.index ["WORDTYPE"], name: "WORDTYPE", using: :btree
  end

  create_table "GIG", primary_key: "GIGID", force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
    t.string   "BilledAs",    limit: 32,         default: "Robyn Hitchcock"
    t.string   "Venue",       limit: 128
    t.integer  "VENUEID",                        default: 0
    t.string   "GigType",     limit: 16
    t.datetime "GigDate"
    t.string   "GigYear",     limit: 4
    t.boolean  "Circa",                          default: false
    t.integer  "SetNum",      limit: 1,          default: 0
    t.datetime "StartTime"
    t.integer  "Length",                         default: 0
    t.string   "Guests",      limit: 64
    t.string   "ShortNote",   limit: 64
    t.string   "Shirts",      limit: 24
    t.text     "Reviews",     limit: 4294967295
    t.boolean  "TapeExists",                     default: false
    t.string   "Performance", limit: 1
    t.string   "Sound",       limit: 1
    t.string   "Rarity",      limit: 1
    t.string   "Format",      limit: 32
    t.string   "Genealogy",   limit: 32
    t.string   "Flaws",       limit: 32
    t.boolean  "Favorite",                       default: false
    t.string   "Master",      limit: 32
    t.string   "Type",        limit: 32,         default: "aud"
    t.text     "Archived",    limit: 4294967295
    t.integer  "FEGID",                          default: 0
    t.datetime "ModifyDate",                     default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["BilledAs"], name: "BilledAs", using: :btree
    t.index ["GigDate"], name: "GigDate", using: :btree
    t.index ["VENUEID"], name: "VENUEID", using: :btree
  end

  create_table "GSET", primary_key: "SETID", force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
    t.integer "GIGID",                   default: 0
    t.integer "SONGID",                  default: 0
    t.integer "Chrono",                  default: 10
    t.string  "Song",         limit: 50
    t.string  "VersionNotes", limit: 32
    t.boolean "Encore",                  default: false
    t.boolean "Segue",                   default: false
    t.boolean "Soundcheck",              default: false
    t.string  "Flaw",         limit: 32
    t.string  "MP3Site",      limit: 4
    t.string  "MP3File",      limit: 64
    t.index ["GIGID"], name: "GIGID", using: :btree
    t.index ["SETID"], name: "SETID", using: :btree
    t.index ["SONGID"], name: "SONGID", using: :btree
  end

  create_table "MAJR", primary_key: "MAJRID", id: :integer, default: 0, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
    t.string  "AlbumTitles",       limit: 64
    t.string  "RecordedBy",        limit: 64
    t.float   "ReleaseYear",       limit: 53
    t.integer "COMPID",                               default: 0
    t.string  "AltVersion",        limit: 128
    t.integer "COMPID2",                              default: 0
    t.string  "FrontImage",        limit: 32
    t.string  "BackImage",         limit: 32
    t.string  "CoverDesigner",     limit: 128
    t.text    "ProductionCredits", limit: 4294967295
    t.text    "Notes",             limit: 4294967295
    t.index ["AlbumTitles"], name: "AlbumTitles", using: :btree
    t.index ["COMPID"], name: "COMPID", using: :btree
    t.index ["RecordedBy"], name: "RecordedBy", using: :btree
  end

  create_table "MEDIA", primary_key: "MCODE", id: :string, limit: 1, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
    t.string "Medium",  limit: 16
    t.string "Media",   limit: 16
    t.string "Caption", limit: 24
    t.string "Abbrev",  limit: 16
    t.index ["MCODE"], name: "MCODE", unique: true, using: :btree
  end

  create_table "MUSO", primary_key: "MUSOID", force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
    t.string  "Name",      limit: 50
    t.boolean "Author",                       default: false
    t.boolean "Performer",                    default: false
    t.boolean "Guest",                        default: false
    t.text    "Notes",     limit: 4294967295
  end

  create_table "Paste Errors", id: false, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
    t.string  "Song"
    t.integer "Disc", limit: 1
    t.string  "Side"
    t.integer "Seq",  limit: 1
    t.string  "Time"
  end

  create_table "SITE", primary_key: "SITEID", id: :string, limit: 4, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
    t.string  "SiteType",       limit: 16
    t.boolean "FriendliesOnly",             default: false
    t.string  "Description",    limit: 64
    t.string  "FTPbase",        limit: 128
    t.string  "HTTPbase",       limit: 128
    t.index ["SITEID"], name: "SITEID", using: :btree
  end

  create_table "SONG", primary_key: "SONGID", force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
    t.string   "Song",            limit: 64,                         null: false
    t.string   "Prefix",          limit: 16
    t.string   "Versions",        limit: 50
    t.string   "Band",            limit: 32
    t.integer  "MUSOID",                             default: 0
    t.integer  "GIGID",                              default: 0
    t.string   "Author",          limit: 40
    t.string   "OrigBand",        limit: 32
    t.string   "AltTitles",       limit: 64
    t.boolean  "Improvised",                         default: false
    t.integer  "MAJRID",                             default: 0
    t.datetime "ApproxDate"
    t.text     "Lyrics",          limit: 4294967295
    t.text     "Tab",             limit: 4294967295
    t.text     "Comments",        limit: 4294967295
    t.text     "RHComments",      limit: 4294967295
    t.string   "CoveredBy",       limit: 32
    t.string   "Instrumentation", limit: 32
    t.integer  "SongLookup",                         default: 0
    t.string   "MP3Site",         limit: 4
    t.string   "MP3File",         limit: 64
    t.index ["MAJRID"], name: "MAJRID", using: :btree
    t.index ["MUSOID"], name: "MUSOID", using: :btree
    t.index ["Song"], name: "Song", using: :btree
  end

  create_table "TRAK", primary_key: "TRAKID", force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
    t.integer "COMPID"
    t.integer "SONGID"
    t.string  "Song",         limit: 64
    t.integer "Disc",         limit: 1,  default: 0
    t.string  "Side",         limit: 1
    t.integer "Seq",          limit: 1,  default: 0
    t.string  "Time",         limit: 6
    t.string  "VersionNotes", limit: 64
    t.boolean "Hidden",                  default: false
    t.index ["Disc"], name: "Disc", using: :btree
    t.index ["SONGID"], name: "SONGID", using: :btree
    t.index ["Seq"], name: "Seq", using: :btree
    t.index ["Side"], name: "Side", using: :btree
  end

  create_table "VENUE", primary_key: "VENUEID", force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
    t.string  "Name",          limit: 48
    t.string  "City",          limit: 24
    t.string  "State",         limit: 16
    t.string  "Country",       limit: 16
    t.boolean "TaperFriendly",            default: false
    t.boolean "Radio",                    default: false
    t.string  "NameSearch",    limit: 48
    t.index ["Name"], name: "Name", using: :btree
    t.index ["NameSearch"], name: "NameSearch", using: :btree
  end

  create_table "XREF", primary_key: "XREFID", id: :string, limit: 12, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
    t.string "XLINK", limit: 32
    t.string "XTEXT"
    t.index ["XREFID"], name: "XREFID", using: :btree
  end

  create_table "performances", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "performanceid"
    t.string   "url"
    t.string   "name"
    t.string   "venue"
    t.integer  "host"
    t.integer  "medium"
    t.integer  "performance_type"
    t.date     "performance_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "song_performances", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "song_id"
    t.integer  "performance_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["performance_id"], name: "index_song_performances_on_performance_id", using: :btree
    t.index ["song_id"], name: "index_song_performances_on_song_id", using: :btree
  end

end
