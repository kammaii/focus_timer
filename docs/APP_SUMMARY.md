# 집중 타이머 (Focus Timer) 프로젝트 요약

## 💡 1. 프로젝트 개요
* **목적:** 다마고치(알 키우기) 요소를 결합하여 사용자의 집중력을 높이고 습관 형성을 돕는 뽀모도로 타이머 앱
* **주요 타겟:** 공부, 업무 등 장시간 집중이 필요한 학생 및 직장인

## 🛠 2. 기술 스택
* **Frontend:** Flutter (Dart)
* **State Management:** GetX
* **Local Storage:** GetStorage (또는 SharedPreferences 기반 LocalStorageProvider)
* **UI/UX:** CircularPercentIndicator, Lottie (AnimalView), Custom Dialogs
* **Audio:** audioplayers

## ✨ 3. 핵심 기능 목록
* **집중/휴식 타이머:** 설정된 시간에 따라 집중과 휴식 사이클 반복
* **다마고치 시스템:** 집중 시간에 비례하여 경험치(XP)를 획득하고 알에서 동물로 진화
* **보상 시스템:** 집중 완료 후 광고 시청을 통해 추가 경험치 획득 가능
* **기록 통계:** 일별 집중 기록 저장 및 연속 집중일(Streak) 계산
* **앰비언트 모드:** 집중 중 장시간 미입력 시 화면을 어둡게 하고 밤하늘 연출로 배터리 절약 및 몰입 유도

## 🗺 4. 화면 구성 및 네비게이션
* **홈 화면 (HomeView):** 타이머 조작 및 다마고치 캐릭터 확인 -> 설정, 기록, 컬렉션 이동
* **설정 화면 (SettingsView):** 집중/휴식 시간, 반복 횟수, 알람 소리, 카테고리 관리
* **기록 화면 (RecordsView):** 누적 집중 시간 및 Streak 통계 확인
* **컬렉션 화면 (CollectionView):** 지금까지 키운 동물 목록 확인

## 🔄 5. 데이터 흐름 및 아키텍처
* **Controller-driven:** `HomeController`가 타이머 로직을 관리하고, `DamagotchiController`가 캐릭터 상태와 경험치를 담당
* **Provider:** `LocalStorageProvider`를 통해 설정 및 기록을 영구 저장
* **XP Logic:** 집중 시간(분)을 기반으로 경험치 계산. 타이머 중단 시에도 1분 이상 집중 시 비례하여 경험치 지급. 최종 수집 기준은 일반 16시간, 스페셜 20시간으로 조정됨.

## 📝 6. 최근 주요 업데이트 내역
* [2026-05-10]: '자랑하기' 이미지 공유 기능 고도화, 동물 수집 기준 시간 하향(16h/20h), 캐릭터별 XP 프로그레스바 추가, 타이머 중단 시 비례 경험치 획득 로직 구현
