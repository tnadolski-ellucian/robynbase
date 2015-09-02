# encoding: UTF-8
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

  create_table "COMP", primary_key: "COMPID", force: true do |t|
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
  end

  add_index "comp", ["Desc"], name: "Desc", using: :btree
  add_index "comp", ["MAJRID"], name: "MAJRID", using: :btree
  add_index "comp", ["MCODE"], name: "MCODE", using: :btree
  add_index "comp", ["Medium"], name: "Medium", using: :btree
  add_index "comp", ["Title"], name: "Title", using: :btree
  add_index "comp", ["Type"], name: "Type", using: :btree

  create_table "FEG", primary_key: "FEGID", force: true do |t|
    t.string "Lastname",  limit: 20
    t.string "Firstname", limit: 20
    t.string "Street",    limit: 35
    t.string "City",      limit: 25
    t.string "State",     limit: 2
    t.string "Zip",       limit: 11
    t.string "Country",   limit: 20
    t.text   "EMail",     limit: 2147483647
    t.text   "URL",       limit: 2147483647
  end

  add_index "feg", ["FEGID"], name: "FEGID", unique: true, using: :btree

  create_table "FEGNAME", id: false, force: true do |t|
    t.string "FIRST",   limit: 24,  null: false
    t.string "LAST",    limit: 32,  null: false
    t.string "FEGNAME", limit: 128
  end

  create_table "FEGWORD", primary_key: "WORDID", force: true do |t|
    t.integer "WORDTYPE",  limit: 1,  default: 0,     null: false
    t.string  "WORDIS",    limit: 32,                 null: false
    t.string  "CONNECTOR", limit: 8
    t.boolean "NICE",                 default: false
  end

  add_index "fegword", ["WORDTYPE"], name: "WORDTYPE", using: :btree

  create_table "GIG", primary_key: "GIGID", force: true do |t|
    t.string    "BilledAs",    limit: 32,         default: "Robyn Hitchcock"
    t.string    "Venue",       limit: 128
    t.integer   "VENUEID",                        default: 0
    t.string    "GigType",     limit: 16
    t.datetime  "GigDate"
    t.string    "GigYear",     limit: 4
    t.boolean   "Circa",                          default: false
    t.integer   "SetNum",      limit: 1,          default: 0
    t.datetime  "StartTime"
    t.integer   "Length",                         default: 0
    t.string    "Guests",      limit: 64
    t.string    "ShortNote",   limit: 64
    t.string    "Shirts",      limit: 24
    t.text      "Reviews",     limit: 2147483647
    t.boolean   "TapeExists",                     default: false
    t.string    "Performance", limit: 1
    t.string    "Sound",       limit: 1
    t.string    "Rarity",      limit: 1
    t.string    "Format",      limit: 32
    t.string    "Genealogy",   limit: 32
    t.string    "Flaws",       limit: 32
    t.boolean   "Favorite",                       default: false
    t.string    "Master",      limit: 32
    t.string    "Type",        limit: 32,         default: "aud"
    t.text      "Archived",    limit: 2147483647
    t.integer   "FEGID",                          default: 0
    t.timestamp "ModifyDate",                                                 null: false
  end

  add_index "gig", ["BilledAs"], name: "BilledAs", using: :btree
  add_index "gig", ["GigDate"], name: "GigDate", using: :btree
  add_index "gig", ["VENUEID"], name: "VENUEID", using: :btree

  create_table "GSET", primary_key: "SETID", force: true do |t|
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
  end

  add_index "gset", ["GIGID"], name: "GIGID", using: :btree
  add_index "gset", ["SETID"], name: "SETID", using: :btree
  add_index "gset", ["SONGID"], name: "SONGID", using: :btree

  create_table "MAJR", primary_key: "MAJRID", force: true do |t|
    t.string  "AlbumTitles",       limit: 64
    t.string  "RecordedBy",        limit: 64
    t.float   "ReleaseYear",       limit: 53
    t.integer "COMPID",                               default: 0
    t.string  "AltVersion",        limit: 128
    t.integer "COMPID2",                              default: 0
    t.string  "FrontImage",        limit: 32
    t.string  "BackImage",         limit: 32
    t.string  "CoverDesigner",     limit: 128
    t.text    "ProductionCredits", limit: 2147483647
    t.text    "Notes",             limit: 2147483647
  end

  add_index "majr", ["AlbumTitles"], name: "AlbumTitles", using: :btree
  add_index "majr", ["COMPID"], name: "COMPID", using: :btree
  add_index "majr", ["RecordedBy"], name: "RecordedBy", using: :btree

  create_table "MEDIA", primary_key: "MCODE", force: true do |t|
    t.string "Medium",  limit: 16
    t.string "Media",   limit: 16
    t.string "Caption", limit: 24
    t.string "Abbrev",  limit: 16
  end

  add_index "media", ["MCODE"], name: "MCODE", unique: true, using: :btree

  create_table "MUSO", primary_key: "MUSOID", force: true do |t|
    t.string  "Name",      limit: 50
    t.boolean "Author",                       default: false
    t.boolean "Performer",                    default: false
    t.boolean "Guest",                        default: false
    t.text    "Notes",     limit: 2147483647
  end

  create_table "Paste Errors", id: false, force: true do |t|
    t.string  "Song"
    t.integer "Disc", limit: 1
    t.string  "Side"
    t.integer "Seq",  limit: 1
    t.string  "Time"
  end

  create_table "SITE", primary_key: "SITEID", force: true do |t|
    t.string  "SiteType",       limit: 16
    t.boolean "FriendliesOnly",             default: false
    t.string  "Description",    limit: 64
    t.string  "FTPbase",        limit: 128
    t.string  "HTTPbase",       limit: 128
  end

  add_index "site", ["SITEID"], name: "SITEID", using: :btree

  create_table "SONG", primary_key: "SONGID", force: true do |t|
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
    t.text     "Lyrics",          limit: 2147483647
    t.text     "Tab",             limit: 2147483647
    t.text     "Comments",        limit: 2147483647
    t.text     "RHComments",      limit: 2147483647
    t.string   "CoveredBy",       limit: 32
    t.string   "Instrumentation", limit: 32
    t.integer  "SongLookup",                         default: 0
    t.string   "MP3Site",         limit: 4
    t.string   "MP3File",         limit: 64
  end

  add_index "song", ["MAJRID"], name: "MAJRID", using: :btree
  add_index "song", ["MUSOID"], name: "MUSOID", using: :btree
  add_index "song", ["Song"], name: "Song", using: :btree

  create_table "TRAK", primary_key: "TRAKID", force: true do |t|
    t.integer "COMPID"
    t.integer "SONGID"
    t.string  "Song",         limit: 64
    t.integer "Disc",         limit: 1,  default: 0
    t.string  "Side",         limit: 1
    t.integer "Seq",          limit: 1,  default: 0
    t.string  "Time",         limit: 6
    t.string  "VersionNotes", limit: 64
    t.boolean "Hidden",                  default: false
  end

  add_index "trak", ["Disc"], name: "Disc", using: :btree
  add_index "trak", ["SONGID"], name: "SONGID", using: :btree
  add_index "trak", ["Seq"], name: "Seq", using: :btree
  add_index "trak", ["Side"], name: "Side", using: :btree

  create_table "VENUE", primary_key: "VENUEID", force: true do |t|
    t.string  "Name",          limit: 48
    t.string  "City",          limit: 24
    t.string  "State",         limit: 16
    t.string  "Country",       limit: 16
    t.boolean "TaperFriendly",            default: false
    t.boolean "Radio",                    default: false
    t.string  "NameSearch",    limit: 48
  end

  add_index "venue", ["Name"], name: "Name", using: :btree
  add_index "venue", ["NameSearch"], name: "NameSearch", using: :btree

  create_table "XREF", primary_key: "XREFID", force: true do |t|
    t.string "XLINK", limit: 32
    t.string "XTEXT"
  end

  add_index "xref", ["XREFID"], name: "XREFID", using: :btree

  create_table "performances", force: true do |t|
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

  create_table "song_performances", force: true do |t|
    t.integer  "songs_id"
    t.integer  "performance_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "song_performances", ["performance_id"], name: "index_song_performances_on_performance_id", using: :btree
  add_index "song_performances", ["songs_id"], name: "index_song_performances_on_songs_id", using: :btree

end
