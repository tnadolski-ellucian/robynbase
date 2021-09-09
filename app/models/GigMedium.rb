class Gigmedium < ApplicationRecord

    belongs_to :gig, foreign_key: "GIGID"

    MEDIA_TYPE = {
        'YouTube' => 1,
        'ArchiveOrg' => 2,
        'ArchiveOrgPlaylist' => 3
    }

end
