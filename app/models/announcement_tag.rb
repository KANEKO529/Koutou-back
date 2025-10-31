# 中間テーブルのモデル
class AnnouncementTag < ApplicationRecord
    belongs_to :announcement
    belongs_to :tag
end
  