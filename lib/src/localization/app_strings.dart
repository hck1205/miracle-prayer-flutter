import "package:flutter/widgets.dart";

import "app_locale.dart";
import "app_locale_scope.dart";

class AppStrings {
  const AppStrings(this.locale);

  final AppLocale locale;

  bool get isKorean => locale == AppLocale.ko;

  static AppStrings of(BuildContext context) {
    return AppStrings(AppLocaleScope.localeOf(context));
  }

  static const Map<AppLocale, Map<String, String>> _values =
      <AppLocale, Map<String, String>>{
        AppLocale.en: _englishValues,
        AppLocale.ko: _koreanValues,
      };

  static const List<String> _englishMonthNames = <String>[
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  static const List<String> _koreanMonthNames = <String>[
    "1월",
    "2월",
    "3월",
    "4월",
    "5월",
    "6월",
    "7월",
    "8월",
    "9월",
    "10월",
    "11월",
    "12월",
  ];

  static const List<String> _englishWeekdayNames = <String>[
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  static const List<String> _koreanWeekdayNames = <String>[
    "월요일",
    "화요일",
    "수요일",
    "목요일",
    "금요일",
    "토요일",
    "일요일",
  ];

  static const List<String> _englishWeekdayLabels = <String>[
    "MON",
    "TUE",
    "WED",
    "THU",
    "FRI",
    "SAT",
    "SUN",
  ];

  static const List<String> _koreanWeekdayLabels = <String>[
    "월",
    "화",
    "수",
    "목",
    "금",
    "토",
    "일",
  ];

  static const Map<String, String> _englishValues = <String, String>{
    "app.title": "Miracle Prayer",
    "common.ok": "OK",
    "common.cancel": "Cancel",
    "common.delete": "Delete",
    "common.edit": "Edit",
    "common.loadMore": "Load more",
    "common.tryAgain": "Try again",
    "common.selected": "SELECTED",
    "locale.switchTo": "Switch language to {language}",
    "locale.ko": "KO",
    "locale.en": "EN",
    "auth.hero.title": "Join the Silence",
    "auth.hero.subtitle": "Take a breath. Enter your quiet space.",
    "auth.googleClientMissing":
        "GOOGLE_CLIENT_ID is missing. Start Flutter with the correct dart define before testing login.",
    "auth.guestModeUnavailable": "Guest mode is not connected yet.",
    "auth.signInWithGoogle": "Sign in with Google",
    "auth.continueAsGuest": "Continue as Guest",
    "auth.logout": "Log out",
    "auth.or": "OR",
    "auth.error.backendRequestFailed":
        "Backend request failed. Make sure miracle-prayer-backend is running.",
    "auth.error.googleInitFailed":
        "Google sign-in could not initialize. Check GOOGLE_CLIENT_ID.",
    "auth.error.googleCanceled": "Google sign-in was canceled.",
    "feed.title": "Prayers",
    "feed.searchPlaceholder": "Search prayers",
    "feed.feedHeaderTitle": "A collective breath.",
    "feed.feedHeaderBody":
        "Join a silent community of voices.\nShare your burdens, find solace in the\nshared spirit of hope.",
    "feed.feedLoading": "Loading prayers...",
    "feed.feedEmptyTitle": "No prayers yet.",
    "feed.feedEmptyBody":
        "The feed will appear here once stories begin to gather.",
    "feed.savedHeaderTitle": "Saved prayers.",
    "feed.savedHeaderBody":
        "Keep the prayers that stayed with you close.\nReturn here whenever you want to revisit them.",
    "feed.savedLoading": "Loading saved prayers...",
    "feed.savedEmptyTitle": "No saved prayers yet.",
    "feed.savedEmptyBody":
        "When a prayer stays with you, tap the bookmark and it will appear here.",
    "feed.searchHeaderIdleTitle": "Search prayers.",
    "feed.searchHeaderIdleBody":
        "Search the community feed by words, topics,\nor short phrases.",
    "feed.searchHeaderShortTitle": "Keep typing.",
    "feed.searchHeaderShortBody":
        "Enter at least 2 characters before we search the feed.",
    "feed.searchHeaderResultsTitle": "Search results.",
    "feed.searchHeaderResultsBody": "Showing prayers that mention \"{query}\".",
    "feed.searchLoading": "Searching prayers...",
    "feed.searchEmptyIdleTitle": "Start typing to search.",
    "feed.searchEmptyIdleBody":
        "Try words like hope, healing, family, or peace.",
    "feed.searchEmptyShortTitle": "Type 2 or more characters.",
    "feed.searchEmptyShortBody":
        "Short queries create noisy results, so search starts at 2 characters.",
    "feed.searchEmptyResultsTitle": "No matching prayers found.",
    "feed.searchEmptyResultsBody":
        "Try a shorter phrase or different keywords.",
    "feed.favoriteSaved": "Saved to your favorites.",
    "feed.favoriteRemoved": "Removed from your favorites.",
    "feed.deleted": "Prayer deleted.",
    "feed.reportSubmitted": "Report submitted. Thank you.",
    "feed.composerWriteTitle": "Write a Prayer",
    "feed.composerEditTitle": "Edit Prayer",
    "feed.composerShare": "SHARE",
    "feed.composerUpdate": "UPDATE",
    "feed.composerCancel": "Cancel",
    "feed.composerTagUnavailable": "Tagging is not connected yet.",
    "feed.composerQuoteUnavailable": "Quote templates are not connected yet.",
    "feed.composerEmpty": "Write your prayer before continuing.",
    "feed.composerMissingEditTarget": "There is no post selected for editing.",
    "feed.shared": "Prayer shared.",
    "feed.updated": "Prayer updated.",
    "feed.draftSaved": "Draft saved.",
    "feed.urgent.loading": "Checking your urgent prayer availability...",
    "feed.urgent.default": "Urgent prayers are limited by a cooldown window.",
    "feed.urgent.enabled":
        "Use this for time-sensitive prayer requests. One urgent prayer every {duration}.",
    "feed.urgent.cooldownOnly":
        "Urgent prayers are limited to one per {duration}.",
    "feed.urgent.availableAgain":
        "Urgent will be available again on {date} at {time}.",
    "feed.urgent.sectionTitle": "Urgent prayers",
    "feed.urgent.sectionBody": "The five most recent urgent prayer requests.",
    "feed.detailTitle": "Prayer detail",
    "feed.footer": "PEACE BE WITH YOU",
    "feed.readMore": "Read more",
    "feed.urgentBadge": "URGENT",
    "feed.favoriteTooltipSave": "Save prayer",
    "feed.favoriteTooltipRemove": "Remove from saved prayers",
    "feed.menuTooltip": "Open post menu",
    "feed.menuEdit": "Edit",
    "feed.menuDelete": "Delete",
    "feed.menuReport": "Report",
    "feed.reportDialogTitle": "Report this prayer",
    "feed.reportDialogBody": "Choose the reason that best fits this post.",
    "feed.reportDialogHint": "Please tell us what happened.",
    "feed.reportSubmit": "Submit report",
    "feed.deleteDialogTitle": "Delete this prayer?",
    "feed.deleteDialogBody":
        "This prayer will be removed from the feed. This action cannot be undone.",
    "feed.draftResumeTitle": "Saved draft found",
    "feed.draftResumeBody":
        "You already have a prayer draft. Would you like to continue writing it or start a new one?",
    "feed.draftResumeStartNew": "Start New",
    "feed.draftResumeContinue": "Continue Writing",
    "feed.reportedTitle": "Already reported",
    "feed.reportedBody":
        "You already reported this prayer. Thank you for letting us know.",
    "feed.editExpiredTitle": "Editing unavailable",
    "feed.editExpiredBody":
        "This prayer can only be edited within 1 hour of posting.",
    "feed.authorAnonymous": "{feedNumber} ANONYMOUS",
    "feed.time.justNow": "Just now",
    "feed.time.minute.one": "1 min ago",
    "feed.time.minute.other": "{count} min ago",
    "feed.time.hour.one": "1 hr ago",
    "feed.time.hour.other": "{count} hrs ago",
    "feed.time.yesterday": "Yesterday",
    "feed.openPrayerDetails": "Open prayer details",
    "feed.identity": "MY IDENTITY",
    "feed.postAnonymously": "POST ANONYMOUSLY",
    "feed.markAsUrgent": "MARK AS URGENT",
    "feed.writePrayerHint": "Write your prayer...",
    "feed.verse.body": "\"Be still, and know that I am God.\"",
    "feed.verse.reference": "(Psalm 46:10)",
    "feed.unavailable": "Unable to load the prayer feed right now.",
    "reaction.amen": "AMEN",
    "reaction.love": "LOVE",
    "reaction.withYou": "WITH YOU",
    "reaction.peace": "PEACE",
    "report.reason.notPrayer.title": "Not a prayer",
    "report.reason.notPrayer.description":
        "Posts that are not actually prayer requests or prayer content.",
    "report.reason.abusive.title": "Abusive or hateful",
    "report.reason.abusive.description":
        "Profanity, personal attacks, defamation, harassment, or hateful content.",
    "report.reason.promotional.title": "Promotional or unrelated",
    "report.reason.promotional.description":
        "Advertisements, spam, or posts that do not fit the purpose of this app.",
    "report.reason.other.title": "Other",
    "report.reason.other.description":
        "Anything else that should be reviewed. Please provide details.",
    "prayer.calendar": "Calendar",
    "prayer.reflections": "Reflections",
    "prayer.hero.calendarTitle": "Hold the days in prayer.",
    "prayer.hero.calendarBody":
        "Keep meaningful dates close, attach the events that need care, and return to each day with intention.",
    "prayer.hero.reflectionsTitle": "A quiet place for your daily prayers.",
    "prayer.hero.reflectionsBody":
        "Write event-linked reflections or simple daily notes, then let the notebook become a gentle record of what you carried.",
    "prayer.hero.notebookSuffix": "PRIVATE PRAYER NOTEBOOK",
    "prayer.timeline": "TIMELINE",
    "prayer.addEvent": "Add Event",
    "prayer.note": "Prayer Note",
    "prayer.emptyDay":
        "No prayer events or notes are attached to this day yet. You can add a meaningful event, or simply keep a daily reflection.",
    "prayer.events": "Events",
    "prayer.notes": "Prayer Notes",
    "prayer.noLinkedNotes": "No prayer notes linked yet.",
    "prayer.linkedNotes.one": "1 prayer note linked.",
    "prayer.linkedNotes.other": "{count} prayer notes linked.",
    "prayer.emptyNotebookTitle": "Your notebook is still quiet.",
    "prayer.emptyNotebookBody":
        "Start with a simple daily reflection and begin recording what is on your heart today.",
    "prayer.dailyReflection": "Daily Reflection",
    "prayer.reply.title": "Response",
    "prayer.reply.section": "Responses",
    "prayer.reply.add": "Add Response",
    "prayer.reply.addTitle": "Add Response to Prayer Note",
    "prayer.reply.editTitle": "Edit Response",
    "prayer.reply.empty": "",
    "prayer.reply.parentLabel": "Original Note",
    "prayer.reply.bodyLabel": "Your Response",
    "prayer.reply.bodyHint":
        "Write what you received, how you responded, or what you are still praying through.",
    "prayer.reply.scriptureLabel": "Related Scripture",
    "prayer.reply.scriptureHint":
        "Add a verse, reference, or short passage that stays with this note.",
    "prayer.reply.saved": "Response saved.",
    "prayer.reply.updated": "Response updated.",
    "prayer.reply.deleted": "Response deleted.",
    "prayer.reply.deleteTitle": "Delete this response?",
    "prayer.reply.deleteBody":
        "This response will be removed from the note. This action cannot be undone.",
    "prayer.quote.body": "\"Peace I leave with you; my peace I give to you.\"",
    "prayer.quote.reference": "JOHN 14:27",
    "prayer.eventAdded": "Event added to your calendar.",
    "prayer.eventUpdated": "Event updated.",
    "prayer.eventDeleted": "Event deleted.",
    "prayer.noteSaved": "Prayer note saved.",
    "prayer.noteUpdated": "Prayer note updated.",
    "prayer.noteDeleted": "Prayer note deleted.",
    "prayer.reflectionAdded": "Reflection added to your notebook.",
    "prayer.addPrayerEvent": "Add Prayer Event",
    "prayer.editPrayerEvent": "Edit Prayer Event",
    "prayer.newPrayerNote": "New Prayer Note",
    "prayer.editPrayerNote": "Edit Prayer Note",
    "prayer.moreActions": "Open item actions",
    "prayer.deleteEventTitle": "Delete this event?",
    "prayer.deleteEventBody":
        "This event will be removed. Linked prayer notes will stay in your notebook and simply be unlinked.",
    "prayer.deleteNoteTitle": "Delete this prayer note?",
    "prayer.deleteNoteBody":
        "This prayer note will be removed from your notebook. This action cannot be undone.",
    "prayer.field.date": "Date",
    "prayer.field.title": "Title",
    "prayer.field.details": "Details",
    "prayer.field.prayer": "Prayer",
    "prayer.field.linkEvent": "Link to Event",
    "prayer.eventTitleHint": "What are you holding in prayer?",
    "prayer.eventDetailsHint":
        "Add the context you want to remember for this day.",
    "prayer.saveEvent": "Save Event",
    "prayer.noteTitleHint": "Give this note a gentle title",
    "prayer.noteBodyHint": "Write what you are carrying today.",
    "prayer.dailyNoteOnly": "Without linking an event",
    "prayer.saveNote": "Save Prayer Note",
    "duration.day.one": "1 day",
    "duration.day.other": "{count} days",
    "duration.hour.one": "1 hour",
    "duration.hour.other": "{count} hours",
    "duration.minute.one": "1 minute",
    "duration.minute.other": "{count} minutes",
    "duration.second.one": "1 second",
    "duration.second.other": "{count} seconds",
  };

  static const Map<String, String> _koreanValues = <String, String>{
    "app.title": "Miracle Prayer",
    "common.ok": "확인",
    "common.cancel": "취소",
    "common.delete": "삭제",
    "common.edit": "수정",
    "common.loadMore": "더 보기",
    "common.tryAgain": "다시 시도",
    "common.selected": "선택됨",
    "locale.switchTo": "{language}(으)로 언어 변경",
    "locale.ko": "KO",
    "locale.en": "EN",
    "auth.hero.title": "고요함 속으로 들어오세요",
    "auth.hero.subtitle": "숨을 고르고, 조용한 기도의 공간에 머물러 보세요.",
    "auth.googleClientMissing":
        "GOOGLE_CLIENT_ID가 없습니다. 로그인 테스트 전에 올바른 dart define으로 Flutter를 실행해 주세요.",
    "auth.guestModeUnavailable": "게스트 모드는 아직 연결되지 않았습니다.",
    "auth.signInWithGoogle": "Google로 로그인",
    "auth.continueAsGuest": "게스트로 계속하기",
    "auth.logout": "로그아웃",
    "auth.or": "또는",
    "auth.error.backendRequestFailed":
        "백엔드 요청에 실패했습니다. miracle-prayer-backend가 실행 중인지 확인해 주세요.",
    "auth.error.googleInitFailed":
        "Google 로그인 초기화에 실패했습니다. GOOGLE_CLIENT_ID를 확인해 주세요.",
    "auth.error.googleCanceled": "Google 로그인이 취소되었습니다.",
    "feed.title": "기도",
    "feed.searchPlaceholder": "기도 검색",
    "feed.feedHeaderTitle": "함께 쉬어가는 숨.",
    "feed.feedHeaderBody":
        "조용히 기도하는 공동체와 함께하세요.\n짐을 나누고, 서로의 소망 안에서\n위로를 만나보세요.",
    "feed.feedLoading": "기도를 불러오는 중...",
    "feed.feedEmptyTitle": "아직 기도가 없어요.",
    "feed.feedEmptyBody": "이야기들이 모이기 시작하면 이곳에 피드가 나타납니다.",
    "feed.savedHeaderTitle": "저장한 기도.",
    "feed.savedHeaderBody":
        "마음에 남은 기도를 가까이 두세요.\n다시 떠올리고 싶을 때 언제든 여기로 돌아오면 됩니다.",
    "feed.savedLoading": "저장한 기도를 불러오는 중...",
    "feed.savedEmptyTitle": "저장한 기도가 아직 없어요.",
    "feed.savedEmptyBody": "마음에 남는 기도에 북마크를 누르면 여기에 모입니다.",
    "feed.searchHeaderIdleTitle": "기도를 검색해 보세요.",
    "feed.searchHeaderIdleBody": "단어, 주제, 짧은 문구로\n공동체 피드를 검색할 수 있어요.",
    "feed.searchHeaderShortTitle": "조금만 더 입력해 주세요.",
    "feed.searchHeaderShortBody": "피드를 검색하려면 2글자 이상 입력해 주세요.",
    "feed.searchHeaderResultsTitle": "검색 결과.",
    "feed.searchHeaderResultsBody": "\"{query}\"이(가) 언급된 기도를 보여드려요.",
    "feed.searchLoading": "기도를 검색하는 중...",
    "feed.searchEmptyIdleTitle": "검색어를 입력해 보세요.",
    "feed.searchEmptyIdleBody": "희망, 치유, 가족, 평안 같은 단어로 시작해 보세요.",
    "feed.searchEmptyShortTitle": "2글자 이상 입력해 주세요.",
    "feed.searchEmptyShortBody": "너무 짧은 검색어는 결과가 불안정해서 2글자부터 검색돼요.",
    "feed.searchEmptyResultsTitle": "일치하는 기도가 없어요.",
    "feed.searchEmptyResultsBody": "더 짧은 문구나 다른 키워드로 다시 시도해 보세요.",
    "feed.favoriteSaved": "즐겨찾기에 저장했어요.",
    "feed.favoriteRemoved": "즐겨찾기에서 제거했어요.",
    "feed.deleted": "기도를 삭제했어요.",
    "feed.reportSubmitted": "신고가 접수되었습니다. 감사합니다.",
    "feed.composerWriteTitle": "기도 작성",
    "feed.composerEditTitle": "기도 수정",
    "feed.composerShare": "공유",
    "feed.composerUpdate": "수정",
    "feed.composerCancel": "취소",
    "feed.composerTagUnavailable": "태그 기능은 아직 연결되지 않았습니다.",
    "feed.composerQuoteUnavailable": "인용문 템플릿은 아직 연결되지 않았습니다.",
    "feed.composerEmpty": "계속하기 전에 기도 내용을 작성해 주세요.",
    "feed.composerMissingEditTarget": "수정할 게시물이 선택되지 않았습니다.",
    "feed.shared": "기도를 공유했어요.",
    "feed.updated": "기도를 수정했어요.",
    "feed.draftSaved": "임시저장했어요.",
    "feed.urgent.loading": "긴급 기도 가능 여부를 확인하는 중...",
    "feed.urgent.default": "긴급 기도는 쿨다운 시간에 따라 제한됩니다.",
    "feed.urgent.enabled":
        "시간 민감한 기도 요청일 때 사용하세요. 긴급 기도는 {duration}마다 한 번만 작성할 수 있어요.",
    "feed.urgent.cooldownOnly": "긴급 기도는 {duration}에 한 번만 작성할 수 있어요.",
    "feed.urgent.availableAgain": "{date} {time}부터 다시 긴급 기도를 사용할 수 있어요.",
    "feed.urgent.sectionTitle": "긴급 기도",
    "feed.urgent.sectionBody": "가장 최근 등록된 긴급 기도 5개를 보여드려요.",
    "feed.detailTitle": "기도 상세",
    "feed.footer": "평안이 함께하길",
    "feed.readMore": "더 보기",
    "feed.urgentBadge": "긴급",
    "feed.favoriteTooltipSave": "기도 저장",
    "feed.favoriteTooltipRemove": "저장한 기도에서 제거",
    "feed.menuTooltip": "게시물 메뉴 열기",
    "feed.menuEdit": "수정",
    "feed.menuDelete": "삭제",
    "feed.menuReport": "신고",
    "feed.reportDialogTitle": "이 기도를 신고할까요?",
    "feed.reportDialogBody": "이 게시물에 가장 알맞은 신고 사유를 선택해 주세요.",
    "feed.reportDialogHint": "어떤 일이 있었는지 알려주세요.",
    "feed.reportSubmit": "신고하기",
    "feed.deleteDialogTitle": "이 기도를 삭제할까요?",
    "feed.deleteDialogBody": "이 기도는 피드에서 삭제되며 되돌릴 수 없습니다.",
    "feed.draftResumeTitle": "저장된 임시글이 있어요",
    "feed.draftResumeBody": "이미 작성 중인 기도 초안이 있습니다. 이어서 작성할지, 새로 시작할지 선택해 주세요.",
    "feed.draftResumeStartNew": "새로 작성",
    "feed.draftResumeContinue": "이어쓰기",
    "feed.reportedTitle": "이미 신고했어요",
    "feed.reportedBody": "이 기도는 이미 신고하셨습니다. 알려주셔서 감사합니다.",
    "feed.editExpiredTitle": "수정할 수 없어요",
    "feed.editExpiredBody": "이 기도는 게시 후 1시간 이내에만 수정할 수 있어요.",
    "feed.authorAnonymous": "{feedNumber} 익명",
    "feed.time.justNow": "방금 전",
    "feed.time.minute.one": "1분 전",
    "feed.time.minute.other": "{count}분 전",
    "feed.time.hour.one": "1시간 전",
    "feed.time.hour.other": "{count}시간 전",
    "feed.time.yesterday": "어제",
    "feed.openPrayerDetails": "기도 상세 열기",
    "feed.identity": "내 정보",
    "feed.postAnonymously": "익명으로 올리기",
    "feed.markAsUrgent": "긴급 기도로 표시",
    "feed.writePrayerHint": "기도를 작성해 보세요...",
    "feed.verse.body": "\"너희는 가만히 있어 내가 하나님 됨을 알지어다.\"",
    "feed.verse.reference": "(시편 46:10)",
    "feed.unavailable": "지금은 기도 피드를 불러올 수 없습니다.",
    "reaction.amen": "아멘",
    "reaction.love": "사랑",
    "reaction.withYou": "함께해요",
    "reaction.peace": "평안",
    "report.reason.notPrayer.title": "기도가 아님",
    "report.reason.notPrayer.description": "실제 기도 요청이나 기도 내용이 아닌 게시물입니다.",
    "report.reason.abusive.title": "욕설 또는 혐오",
    "report.reason.abusive.description":
        "욕설, 인신공격, 명예훼손, 괴롭힘, 혐오 표현이 포함된 내용입니다.",
    "report.reason.promotional.title": "홍보 또는 무관한 내용",
    "report.reason.promotional.description": "광고, 스팸 또는 이 앱의 목적과 맞지 않는 게시물입니다.",
    "report.reason.other.title": "기타",
    "report.reason.other.description": "그 외 검토가 필요한 내용입니다. 자세한 내용을 적어 주세요.",
    "prayer.calendar": "캘린더",
    "prayer.reflections": "묵상노트",
    "prayer.hero.calendarTitle": "날들을 기도로 품어보세요.",
    "prayer.hero.calendarBody":
        "의미 있는 날짜를 가까이 두고, 돌봐야 할 사건을 연결해 두세요. 그리고 매일의 자리에 다시 마음을 놓아보세요.",
    "prayer.hero.reflectionsTitle": "매일의 기도를 담는 조용한 공간.",
    "prayer.hero.reflectionsBody":
        "사건과 연결된 묵상이나 하루의 짧은 기도 메모를 남겨 두세요. 시간이 지나며 마음의 기록이 차분히 쌓여갈 거예요.",
    "prayer.hero.notebookSuffix": "개인 기도 노트",
    "prayer.timeline": "타임라인",
    "prayer.addEvent": "이벤트 추가",
    "prayer.note": "기도 노트",
    "prayer.emptyDay":
        "이 날짜에는 아직 기도 이벤트나 노트가 없어요. 의미 있는 일을 남기거나, 하루의 짧은 묵상부터 시작해 보세요.",
    "prayer.events": "이벤트",
    "prayer.notes": "기도 노트",
    "prayer.noLinkedNotes": "연결된 기도 노트가 아직 없어요.",
    "prayer.linkedNotes.one": "기도 노트 1개가 연결되어 있어요.",
    "prayer.linkedNotes.other": "기도 노트 {count}개가 연결되어 있어요.",
    "prayer.emptyNotebookTitle": "아직 노트가 조용하네요.",
    "prayer.emptyNotebookBody": "간단한 하루 묵상부터 시작하고 오늘 마음에 있는 기도를 기록해 보세요.",
    "prayer.dailyReflection": "하루 묵상",
    "prayer.reply.title": "응답",
    "prayer.reply.section": "응답",
    "prayer.reply.add": "응답 남기기",
    "prayer.reply.addTitle": "기도 노트에 응답 남기기",
    "prayer.reply.editTitle": "응답 수정",
    "prayer.reply.empty": "",
    "prayer.reply.parentLabel": "원문 노트",
    "prayer.reply.bodyLabel": "내 응답",
    "prayer.reply.bodyHint": "어떤 응답을 받았는지, 지금 무엇을 붙들고 기도하는지 적어 보세요.",
    "prayer.reply.scriptureLabel": "관련 말씀 구절",
    "prayer.reply.scriptureHint": "이 노트와 함께 붙들고 싶은 말씀이나 구절을 남겨 보세요.",
    "prayer.reply.saved": "응답이 저장되었어요.",
    "prayer.reply.updated": "응답이 수정되었어요.",
    "prayer.reply.deleted": "응답이 삭제되었어요.",
    "prayer.reply.deleteTitle": "이 응답을 삭제할까요?",
    "prayer.reply.deleteBody": "이 응답은 노트에서 삭제되며 되돌릴 수 없습니다.",
    "prayer.quote.body": "\"평안을 너희에게 끼치노니 곧 나의 평안을 너희에게 주노라.\"",
    "prayer.quote.reference": "요한복음 14:27",
    "prayer.eventAdded": "이벤트를 캘린더에 추가했어요.",
    "prayer.eventUpdated": "이벤트를 수정했어요.",
    "prayer.eventDeleted": "이벤트를 삭제했어요.",
    "prayer.noteSaved": "기도 노트를 저장했어요.",
    "prayer.noteUpdated": "기도 노트를 수정했어요.",
    "prayer.noteDeleted": "기도 노트를 삭제했어요.",
    "prayer.reflectionAdded": "묵상을 노트에 추가했어요.",
    "prayer.addPrayerEvent": "기도 이벤트 추가",
    "prayer.editPrayerEvent": "기도 이벤트 수정",
    "prayer.newPrayerNote": "새 기도 노트",
    "prayer.editPrayerNote": "기도 노트 수정",
    "prayer.moreActions": "항목 메뉴 열기",
    "prayer.deleteEventTitle": "이 이벤트를 삭제할까요?",
    "prayer.deleteEventBody":
        "이 이벤트는 삭제됩니다. 연결된 기도 노트는 노트북에 남고, 이벤트 연결만 해제됩니다.",
    "prayer.deleteNoteTitle": "이 기도 노트를 삭제할까요?",
    "prayer.deleteNoteBody": "이 기도 노트는 노트북에서 삭제되며 되돌릴 수 없습니다.",
    "prayer.field.date": "날짜",
    "prayer.field.title": "제목",
    "prayer.field.details": "상세 내용",
    "prayer.field.prayer": "기도",
    "prayer.field.linkEvent": "이벤트 연결",
    "prayer.eventTitleHint": "무엇을 위해 기도하고 있나요?",
    "prayer.eventDetailsHint": "이 날을 기억하고 싶은 배경을 적어 보세요.",
    "prayer.saveEvent": "이벤트 저장",
    "prayer.noteTitleHint": "이 노트의 제목을 적어 보세요",
    "prayer.noteBodyHint": "오늘 마음에 담고 있는 기도를 적어 보세요.",
    "prayer.dailyNoteOnly": "이벤트 없이 기록하기",
    "prayer.saveNote": "기도 노트 저장",
    "duration.day.one": "1일",
    "duration.day.other": "{count}일",
    "duration.hour.one": "1시간",
    "duration.hour.other": "{count}시간",
    "duration.minute.one": "1분",
    "duration.minute.other": "{count}분",
    "duration.second.one": "1초",
    "duration.second.other": "{count}초",
  };

  Map<String, String> get _localizedValues =>
      _values[locale] ?? _values[AppLocale.en]!;

  String _text(String key, [Map<String, String> placeholders = const {}]) {
    final String template =
        _localizedValues[key] ?? _values[AppLocale.en]![key] ?? key;

    return placeholders.entries.fold(template, (
      String result,
      MapEntry<String, String> entry,
    ) {
      return result.replaceAll("{${entry.key}}", entry.value);
    });
  }

  String get appTitle => _text("app.title");
  String get ok => _text("common.ok");
  String get cancel => _text("common.cancel");
  String get delete => _text("common.delete");
  String get edit => _text("common.edit");
  String get loadMore => _text("common.loadMore");
  String get tryAgain => _text("common.tryAgain");
  String get selected => _text("common.selected");
  String get localeLabelKo => _text("locale.ko");
  String get localeLabelEn => _text("locale.en");
  String localeSwitchSemantics(String language) =>
      _text("locale.switchTo", <String, String>{"language": language});
  String get authHeroTitle => _text("auth.hero.title");
  String get authHeroSubtitle => _text("auth.hero.subtitle");
  String get authGoogleClientMissing => _text("auth.googleClientMissing");
  String get authGuestModeUnavailable => _text("auth.guestModeUnavailable");
  String get authSignInWithGoogle => _text("auth.signInWithGoogle");
  String get authContinueAsGuest => _text("auth.continueAsGuest");
  String get authLogout => _text("auth.logout");
  String get authOr => _text("auth.or");
  String get feedTitle => _text("feed.title");
  String get feedSearchPlaceholder => _text("feed.searchPlaceholder");
  String get feedHeaderTitle => _text("feed.feedHeaderTitle");
  String get feedHeaderBody => _text("feed.feedHeaderBody");
  String get feedLoading => _text("feed.feedLoading");
  String get feedEmptyTitle => _text("feed.feedEmptyTitle");
  String get feedEmptyBody => _text("feed.feedEmptyBody");
  String get savedHeaderTitle => _text("feed.savedHeaderTitle");
  String get savedHeaderBody => _text("feed.savedHeaderBody");
  String get savedLoading => _text("feed.savedLoading");
  String get savedEmptyTitle => _text("feed.savedEmptyTitle");
  String get savedEmptyBody => _text("feed.savedEmptyBody");
  String get searchHeaderIdleTitle => _text("feed.searchHeaderIdleTitle");
  String get searchHeaderIdleBody => _text("feed.searchHeaderIdleBody");
  String get searchHeaderShortTitle => _text("feed.searchHeaderShortTitle");
  String get searchHeaderShortBody => _text("feed.searchHeaderShortBody");
  String get searchHeaderResultsTitle => _text("feed.searchHeaderResultsTitle");
  String searchHeaderResultsBody(String query) =>
      _text("feed.searchHeaderResultsBody", <String, String>{"query": query});
  String get searchLoading => _text("feed.searchLoading");
  String get searchEmptyIdleTitle => _text("feed.searchEmptyIdleTitle");
  String get searchEmptyIdleBody => _text("feed.searchEmptyIdleBody");
  String get searchEmptyShortTitle => _text("feed.searchEmptyShortTitle");
  String get searchEmptyShortBody => _text("feed.searchEmptyShortBody");
  String get searchEmptyResultsTitle => _text("feed.searchEmptyResultsTitle");
  String get searchEmptyResultsBody => _text("feed.searchEmptyResultsBody");
  String get favoriteSaved => _text("feed.favoriteSaved");
  String get favoriteRemoved => _text("feed.favoriteRemoved");
  String get feedDeleted => _text("feed.deleted");
  String get feedReportSubmitted => _text("feed.reportSubmitted");
  String get composerWriteTitle => _text("feed.composerWriteTitle");
  String get composerEditTitle => _text("feed.composerEditTitle");
  String get composerShare => _text("feed.composerShare");
  String get composerUpdate => _text("feed.composerUpdate");
  String get composerCancel => _text("feed.composerCancel");
  String get composerTagUnavailable => _text("feed.composerTagUnavailable");
  String get composerQuoteUnavailable => _text("feed.composerQuoteUnavailable");
  String get composerEmpty => _text("feed.composerEmpty");
  String get composerMissingEditTarget =>
      _text("feed.composerMissingEditTarget");
  String get feedShared => _text("feed.shared");
  String get feedUpdated => _text("feed.updated");
  String get draftSaved => _text("feed.draftSaved");
  String get urgentLoading => _text("feed.urgent.loading");
  String get urgentDefault => _text("feed.urgent.default");
  String urgentEnabled(String duration) =>
      _text("feed.urgent.enabled", <String, String>{"duration": duration});
  String urgentCooldownOnly(String duration) =>
      _text("feed.urgent.cooldownOnly", <String, String>{"duration": duration});
  String urgentAvailableAgain({required String date, required String time}) =>
      _text("feed.urgent.availableAgain", <String, String>{
        "date": date,
        "time": time,
      });
  String get urgentSectionTitle => _text("feed.urgent.sectionTitle");
  String get urgentSectionBody => _text("feed.urgent.sectionBody");
  String get feedDetailTitle => _text("feed.detailTitle");
  String get feedFooter => _text("feed.footer");
  String get feedReadMore => _text("feed.readMore");
  String get urgentBadge => _text("feed.urgentBadge");
  String get favoriteTooltipSave => _text("feed.favoriteTooltipSave");
  String get favoriteTooltipRemove => _text("feed.favoriteTooltipRemove");
  String get postMenuTooltip => _text("feed.menuTooltip");
  String get postMenuEdit => _text("feed.menuEdit");
  String get postMenuDelete => _text("feed.menuDelete");
  String get postMenuReport => _text("feed.menuReport");
  String get reportDialogTitle => _text("feed.reportDialogTitle");
  String get reportDialogBody => _text("feed.reportDialogBody");
  String get reportDialogHint => _text("feed.reportDialogHint");
  String get reportSubmit => _text("feed.reportSubmit");
  String get deleteDialogTitle => _text("feed.deleteDialogTitle");
  String get deleteDialogBody => _text("feed.deleteDialogBody");
  String get draftResumeTitle => _text("feed.draftResumeTitle");
  String get draftResumeBody => _text("feed.draftResumeBody");
  String get draftResumeStartNew => _text("feed.draftResumeStartNew");
  String get draftResumeContinue => _text("feed.draftResumeContinue");
  String get reportedTitle => _text("feed.reportedTitle");
  String get reportedBody => _text("feed.reportedBody");
  String get editExpiredTitle => _text("feed.editExpiredTitle");
  String get editExpiredBody => _text("feed.editExpiredBody");
  String feedAuthorAnonymous(String feedNumber) =>
      _text("feed.authorAnonymous", <String, String>{"feedNumber": feedNumber});
  String get feedTimeJustNow => _text("feed.time.justNow");
  String feedTimeMinute(int count) => _text(
    count == 1 ? "feed.time.minute.one" : "feed.time.minute.other",
    <String, String>{"count": "$count"},
  );
  String feedTimeHour(int count) => _text(
    count == 1 ? "feed.time.hour.one" : "feed.time.hour.other",
    <String, String>{"count": "$count"},
  );
  String get feedTimeYesterday => _text("feed.time.yesterday");
  String get openPrayerDetails => _text("feed.openPrayerDetails");
  String get identityLabel => _text("feed.identity");
  String get postAnonymously => _text("feed.postAnonymously");
  String get markAsUrgent => _text("feed.markAsUrgent");
  String get writePrayerHint => _text("feed.writePrayerHint");
  String get feedVerseBody => _text("feed.verse.body");
  String get feedVerseReference => _text("feed.verse.reference");
  String get feedUnavailable => _text("feed.unavailable");
  String get prayerCalendar => _text("prayer.calendar");
  String get prayerReflections => _text("prayer.reflections");
  String get prayerHeroCalendarTitle => _text("prayer.hero.calendarTitle");
  String get prayerHeroCalendarBody => _text("prayer.hero.calendarBody");
  String get prayerHeroReflectionsTitle =>
      _text("prayer.hero.reflectionsTitle");
  String get prayerHeroReflectionsBody => _text("prayer.hero.reflectionsBody");
  String get prayerHeroNotebookSuffix => _text("prayer.hero.notebookSuffix");
  String get prayerTimeline => _text("prayer.timeline");
  String get prayerAddEvent => _text("prayer.addEvent");
  String get prayerNote => _text("prayer.note");
  String get prayerEmptyDay => _text("prayer.emptyDay");
  String get prayerEvents => _text("prayer.events");
  String get prayerNotes => _text("prayer.notes");
  String get prayerNoLinkedNotes => _text("prayer.noLinkedNotes");
  String prayerLinkedNotes(int count) => _text(
    count == 1 ? "prayer.linkedNotes.one" : "prayer.linkedNotes.other",
    <String, String>{"count": "$count"},
  );
  String get prayerEmptyNotebookTitle => _text("prayer.emptyNotebookTitle");
  String get prayerEmptyNotebookBody => _text("prayer.emptyNotebookBody");
  String get prayerDailyReflection => _text("prayer.dailyReflection");
  String get prayerReplyTitle => _text("prayer.reply.title");
  String get prayerReplySection => _text("prayer.reply.section");
  String get prayerAddReply => _text("prayer.reply.add");
  String get prayerAddReplyTitle => _text("prayer.reply.addTitle");
  String get prayerEditReplyTitle => _text("prayer.reply.editTitle");
  String get prayerReplyEmpty => _text("prayer.reply.empty");
  String get prayerReplyParentLabel => _text("prayer.reply.parentLabel");
  String get prayerReplyBodyLabel => _text("prayer.reply.bodyLabel");
  String get prayerReplyBodyHint => _text("prayer.reply.bodyHint");
  String get prayerReplyScriptureLabel => _text("prayer.reply.scriptureLabel");
  String get prayerReplyScriptureHint => _text("prayer.reply.scriptureHint");
  String get prayerReplySaved => _text("prayer.reply.saved");
  String get prayerReplyUpdated => _text("prayer.reply.updated");
  String get prayerReplyDeleted => _text("prayer.reply.deleted");
  String get prayerDeleteReplyTitle => _text("prayer.reply.deleteTitle");
  String get prayerDeleteReplyBody => _text("prayer.reply.deleteBody");
  String get prayerQuoteBody => _text("prayer.quote.body");
  String get prayerQuoteReference => _text("prayer.quote.reference");
  String get prayerEventAdded => _text("prayer.eventAdded");
  String get prayerEventUpdated => _text("prayer.eventUpdated");
  String get prayerEventDeleted => _text("prayer.eventDeleted");
  String get prayerNoteSaved => _text("prayer.noteSaved");
  String get prayerNoteUpdated => _text("prayer.noteUpdated");
  String get prayerNoteDeleted => _text("prayer.noteDeleted");
  String get prayerReflectionAdded => _text("prayer.reflectionAdded");
  String get prayerAddPrayerEvent => _text("prayer.addPrayerEvent");
  String get prayerEditPrayerEvent => _text("prayer.editPrayerEvent");
  String get prayerNewPrayerNote => _text("prayer.newPrayerNote");
  String get prayerEditPrayerNote => _text("prayer.editPrayerNote");
  String get prayerMoreActions => _text("prayer.moreActions");
  String get prayerDeleteEventTitle => _text("prayer.deleteEventTitle");
  String get prayerDeleteEventBody => _text("prayer.deleteEventBody");
  String get prayerDeleteNoteTitle => _text("prayer.deleteNoteTitle");
  String get prayerDeleteNoteBody => _text("prayer.deleteNoteBody");
  String get prayerFieldDate => _text("prayer.field.date");
  String get prayerFieldTitle => _text("prayer.field.title");
  String get prayerFieldDetails => _text("prayer.field.details");
  String get prayerFieldPrayer => _text("prayer.field.prayer");
  String get prayerFieldLinkEvent => _text("prayer.field.linkEvent");
  String get prayerEventTitleHint => _text("prayer.eventTitleHint");
  String get prayerEventDetailsHint => _text("prayer.eventDetailsHint");
  String get prayerSaveEvent => _text("prayer.saveEvent");
  String get prayerNoteTitleHint => _text("prayer.noteTitleHint");
  String get prayerNoteBodyHint => _text("prayer.noteBodyHint");
  String get prayerDailyNoteOnly => _text("prayer.dailyNoteOnly");
  String get prayerSaveNote => _text("prayer.saveNote");
  String reactionAmen() => _text("reaction.amen");
  String reactionLove() => _text("reaction.love");
  String reactionWithYou() => _text("reaction.withYou");
  String reactionPeace() => _text("reaction.peace");
  String reportReasonNotPrayerTitle() => _text("report.reason.notPrayer.title");
  String reportReasonNotPrayerDescription() =>
      _text("report.reason.notPrayer.description");
  String reportReasonAbusiveTitle() => _text("report.reason.abusive.title");
  String reportReasonAbusiveDescription() =>
      _text("report.reason.abusive.description");
  String reportReasonPromotionalTitle() =>
      _text("report.reason.promotional.title");
  String reportReasonPromotionalDescription() =>
      _text("report.reason.promotional.description");
  String reportReasonOtherTitle() => _text("report.reason.other.title");
  String reportReasonOtherDescription() =>
      _text("report.reason.other.description");

  String formatDuration(int seconds) {
    const int secondsPerDay = 24 * 60 * 60;
    const int secondsPerHour = 60 * 60;

    if (seconds % secondsPerDay == 0) {
      final int count = seconds ~/ secondsPerDay;
      return _text(
        count == 1 ? "duration.day.one" : "duration.day.other",
        <String, String>{"count": "$count"},
      );
    }

    if (seconds % secondsPerHour == 0) {
      final int count = seconds ~/ secondsPerHour;
      return _text(
        count == 1 ? "duration.hour.one" : "duration.hour.other",
        <String, String>{"count": "$count"},
      );
    }

    if (seconds % 60 == 0) {
      final int count = seconds ~/ 60;
      return _text(
        count == 1 ? "duration.minute.one" : "duration.minute.other",
        <String, String>{"count": "$count"},
      );
    }

    return _text(
      seconds == 1 ? "duration.second.one" : "duration.second.other",
      <String, String>{"count": "$seconds"},
    );
  }

  String localizeAuthError(String message) {
    return switch (message) {
      "auth.backend_request_failed" => _text("auth.error.backendRequestFailed"),
      "auth.google_init_failed" => _text("auth.error.googleInitFailed"),
      "auth.google_canceled" => _text("auth.error.googleCanceled"),
      _ => message,
    };
  }

  String localizeFeedError(String message) {
    return switch (message) {
      "feed.unavailable" => _text("feed.unavailable"),
      "You already reported this prayer." => _text("feed.reportedBody"),
      _ => message,
    };
  }

  List<String> get monthNames =>
      isKorean ? _koreanMonthNames : _englishMonthNames;

  List<String> get weekdayNames =>
      isKorean ? _koreanWeekdayNames : _englishWeekdayNames;

  List<String> get weekdayLabels =>
      isKorean ? _koreanWeekdayLabels : _englishWeekdayLabels;

  String formatMonthDay(DateTime date) {
    if (isKorean) {
      return "${date.month}월 ${date.day}일";
    }

    return "${date.month}/${date.day}";
  }
}

extension AppStringsBuildContextX on BuildContext {
  AppStrings get strings => AppStrings.of(this);
}
