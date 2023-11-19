alias HousekeepingBook.Categories

middle_categories = [
  "수입",
  "자산증식",
  "예비비",
  "대출이자",
  "보험",
  "주거비",
  "주거/통신",
  "개인경비",
  "교통",
  "식비",
  "생활용품",
  "미용비",
  "건강",
  "자기개발",
  "기타"
]

categories = [
  "월급",
  "부수입",
  "주거대출이자",
  "신용대출이자",
  "기타대출이자",
  "관리비",
  "공과금",
  "인터넷",
  "월세",
  "주거/통신 기타",
  "통신비",
  "경비지출",
  "구독/기타",
  "후불교통",
  "교통 기타",
  "마트/장보기",
  "편의점",
  "외식",
  "배달",
  "빵집",
  "카페",
  "모임",
  "소모품",
  "피트니스 소모품",
  "가전",
  "가구",
  "기타/인테리어",
  "의류/잡화",
  "미용/헤어",
  "세탁/수선",
  "병원",
  "약국",
  "영양제",
  "건강 기타",
  "공부",
  "운동",
  "도서/문화생활",
  "자기개발 기타",
  "기타"
]

Categories.delete_all_categories()

[
  "고정비",
  "상비비"
]
|> Enum.map(fn
  name ->
    %{name: name, type: :expense}
    |> Categories.create_category()
end)

middle_categories
|> Enum.map(fn
  "수입" ->
    %{name: "수입", type: :income}

  name when name in ["자산증식", "예비비"] ->
    %{name: name, type: :saving}

  name when name in ["대출이자", "보험", "주거비"] ->
    parent = Categories.get_category_by_name_and_type!("고정비", :expense)
    %{name: name, type: :expense, parent_id: parent.id}

  name ->
    parent = Categories.get_category_by_name_and_type!("상비비", :expense)
    %{name: name, type: :expense, parent_id: parent.id}
end)
|> Enum.map(fn attrs -> Categories.create_category(attrs) end)

categories
|> Enum.map(fn
  name when name in ["월급", "부수입"] ->
    parent = Categories.get_category_by_name_and_type!("수입", :income)

    %{name: name, type: :income, parent_id: parent.id}
    |> Categories.create_category()

  name ->
    parent_name =
      case name do
        name when name in ["주거대출이자", "신용대출이자"] -> "대출이자"
        name when name in ["관리비", "공과금", "월세", "인터넷"] -> "주거비"
        _ -> "기타"
      end

    parent = Categories.get_category_by_name_and_type!(parent_name, :expense)

    %{name: name, type: :expense, parent_id: parent.id}
    |> Categories.create_category()
end)
