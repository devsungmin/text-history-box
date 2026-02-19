APP_NAME = TextHistoryBox
VERSION = 1.0.1
BUILD_DIR = .build
DEBUG_BIN = $(BUILD_DIR)/debug/$(APP_NAME)
RELEASE_BIN = $(BUILD_DIR)/release/$(APP_NAME)
APP_BUNDLE = $(BUILD_DIR)/$(APP_NAME).app
DMG_NAME = $(APP_NAME)-$(VERSION).dmg
DMG_DIR = $(BUILD_DIR)/dmg
INSTALL_DIR = /Applications

.PHONY: build release run app dmg install uninstall xcode clean

# 디버그 빌드
build:
	swift build

# 릴리즈 빌드
release:
	swift build -c release

# 빌드 후 실행
run: build
	$(DEBUG_BIN)

# .app 번들 생성 (릴리즈)
app: release
	mkdir -p "$(APP_BUNDLE)/Contents/MacOS"
	mkdir -p "$(APP_BUNDLE)/Contents/Resources"
	cp $(RELEASE_BIN) "$(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)"
	cp Info.plist "$(APP_BUNDLE)/Contents/Info.plist"
	cp AppIcon.icns "$(APP_BUNDLE)/Contents/Resources/AppIcon.icns"
	@echo "✅ $(APP_BUNDLE) 생성 완료"

# DMG 설치 패키지 생성
dmg: app
	rm -rf "$(DMG_DIR)"
	mkdir -p "$(DMG_DIR)"
	cp -R "$(APP_BUNDLE)" "$(DMG_DIR)/"
	ln -s $(INSTALL_DIR) "$(DMG_DIR)/Applications"
	hdiutil create -volname "$(APP_NAME)" \
		-srcfolder "$(DMG_DIR)" \
		-ov -format UDZO \
		"$(BUILD_DIR)/$(DMG_NAME)"
	rm -rf "$(DMG_DIR)"
	@echo "✅ $(BUILD_DIR)/$(DMG_NAME) 생성 완료"

# /Applications에 설치
install: app
	cp -R "$(APP_BUNDLE)" "$(INSTALL_DIR)/$(APP_NAME).app"
	@echo "✅ $(INSTALL_DIR)/$(APP_NAME).app 설치 완료"
	@echo "Spotlight에서 '$(APP_NAME)'으로 검색하거나 open $(INSTALL_DIR)/$(APP_NAME).app 으로 실행하세요"

# /Applications에서 제거
uninstall:
	rm -rf "$(INSTALL_DIR)/$(APP_NAME).app"
	@echo "✅ $(APP_NAME) 제거 완료"

# Xcode에서 열기
xcode:
	open Package.swift

# 빌드 산출물 정리
clean:
	swift package clean
	rm -rf $(BUILD_DIR)
