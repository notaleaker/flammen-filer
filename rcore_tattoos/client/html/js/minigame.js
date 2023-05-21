const AppMinigame = new Vue({
    el: '#minigameApp',
    data: {
        visible: false,
        difficulty: false,
        cursor: null,
        closeKey: 'backspace',
        texts: {},
        showConfirmDialog: false,
    },
});

function initMinigame() {
    // Refs
    let minigame;
    let cursor;
    let balanceArea;
    let fillArea;
    let tutorialLine;
    let confirmLine;

    // Settings
    let isCursorMoving = false;
    let isBalanceChecking = false;
    let score = 0;
    let maxScore = Number.MAX_VALUE;
    let confirmDialogTimeout = 3000;
    let tutorialReadTime = 4000;
    let tutorialReadTimeAfter = 500;

    const clamp = (num, min, max) => Math.min(Math.max(num, min), max);

    const getRandomInt = (min, max) => {
        min = Math.ceil(min);
        max = Math.floor(max);
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    const post = (url, data) => {
        let xhr = new XMLHttpRequest();
        xhr.open("POST", url);
        xhr.send(JSON.stringify(data));
    }

    const addScore = (addedScore) => {
        score += addedScore / AppMinigame.difficulty;
        
        const newWidth = clamp(score, 0, balanceArea.clientWidth);
        fillArea.style.width = `${newWidth}px`;
        fillArea.style.height = `${newWidth}px`;
        
        if (score >= maxScore) {
            handleSuccess()
        }
    }

    function doRefsExist() {
        return !!minigame && !!cursor && !!balanceArea && !!fillArea && !!tutorialLine;
    }

    function setBalanceChecking(isChecking) {
        isBalanceChecking = isChecking

        if (isBalanceChecking) {
            setTimeout(() => {
                if (!doRefsExist()) return;

                const cursorWidth = cursor.clientWidth;
                const cursPos = cursor.getBoundingClientRect();
                const areaPos = balanceArea.getBoundingClientRect();

                const isVertically = cursPos.top >= areaPos.top && cursPos.bottom <= areaPos.bottom;
                const isHorizontally = cursPos.left >= areaPos.left && cursPos.right <= areaPos.right;

                if (isVertically && isHorizontally) {
                    addScore(1)
                }

                setBalanceChecking(isBalanceChecking)
            }, 10);
        }
    }

    function setNewCursorPos(forceStrength, left, top, withWidth) {
        if (!doRefsExist()) return;

        const width = withWidth ? cursor.clientWidth : 0
        const leftForce = getRandomInt(-forceStrength, forceStrength)
        const topForce = getRandomInt(-forceStrength, forceStrength)
    
        const newLeft = clamp(leftForce + left - (width / 2), 0, window.innerWidth - width)
        const newTop = clamp(topForce + top - (width / 2), 0, window.innerHeight - width)
    
        cursor.style.left = newLeft + 'px';
        cursor.style.top = newTop + 'px';
    }

    let isMoveThrottled = false;
    function moveCursor(e) {
        if (isMoveThrottled) return;
        isMoveThrottled = true;
        setTimeout(function () { isMoveThrottled = false; }, 100);
    
        setNewCursorPos(100, e.pageX, e.pageY, true)
    }

    function setCursorTracking(isTracking) {
        isTracking
            ? document.addEventListener('mousemove', moveCursor)
            : document.removeEventListener('mousemove', moveCursor);
    }

    function setCursorMoving(isMoving) {
        isCursorMoving = isMoving

        if (isCursorMoving) {
            setTimeout(() => {
                if (!doRefsExist()) return;

                const elPos = cursor.getBoundingClientRect()
                setNewCursorPos(100, elPos.left, elPos.top)
                setCursorMoving(isCursorMoving)
            }, 100);
        }
    }

    function endMinigame(result) {
        post('https://rcore_tattoos/tattooMinigameResult', {result: result})
    }

    function handleKeyPress(e) {
        if (AppMinigame.closeKey == e.key.toLowerCase()) {
            endMinigame(false)
        }
    }

    function setCloseKeysListener(isListen) {
        isListen
            ? document.addEventListener('keyup', handleKeyPress)
            : document.removeEventListener('keyup', handleKeyPress);
    }

    function resetValues() {
        score = 0;
        maxScore = balanceArea.clientWidth;
    }

    function minigameState(isStart) {
        setCursorTracking(isStart)
        setCloseKeysListener(isStart)
        
        if (!doRefsExist()) return;
        
        resetValues()
        setBalanceChecking(isStart)
        setCursorMoving(isStart)
    }

    function hideElement(el, time) {
        el.style.transition = `opacity ${time || 0.5}s`;
        el.style.opacity = 0;
    }

    function handleSuccess() {
        if (!doRefsExist()) return;
        hideElement(cursor)
        minigameState(false)
        fillArea.style.animation = 'minigameSuccess 1s ease-in 0s infinite normal forwards';
        
        setTimeout(() => {
            if (!doRefsExist()) return;
            hideElement(minigame, 1)

            setTimeout(() => {
                if (!doRefsExist()) return;
                endMinigame(true)
            }, 
            1000);
        }, 1000);
    }

    function handleTutorialReadTime(isVisible) {
        if (!doRefsExist()) return;
        tutorialLine.style.transition = 'unset';
        tutorialLine.style.width = '1px';

        if (isVisible) {
            tutorialLine.style.transition = `width ${tutorialReadTime}ms ease-out`;
            setTimeout(() => {
                tutorialLine.style.width = '100%';
                tutorialReadTime = tutorialReadTimeAfter;
            }, 0);
        }
    }

    function handleConfirmExpiration() {
        if (!confirmLine) return;
        confirmLine.style.transition = 'unset';
        confirmLine.style.width = '1px';
        
        confirmLine.style.transition = `width ${confirmDialogTimeout}ms`;
        setTimeout(() => {
            confirmLine.style.width = '100%';
        }, 0);        
    }

    window.addEventListener("message", function (event) {
        const item = event.data;
        if (item.type == "minigame") {
            AppMinigame.visible = item.visible || false;

            if (item.texts && item.texts.length != 0) {
                AppMinigame.texts = JSON.parse(item.texts);
            }

            if (item.closeKey) {
                AppMinigame.closeKey = item.closeKey.toLowerCase();
            }

            if (item.confirmDialog && Object.keys(item.confirmDialog).length) {
                AppMinigame.showConfirmDialog = item.confirmDialog.visible;
                confirmDialogTimeout = item.confirmDialog.timeout || 3000;
            } else {
                AppMinigame.showConfirmDialog = false;
            }

            if (item.tutorialReadTime) {
                tutorialReadTimeAfter = item.tutorialReadTime
            }
            if (item.tutorialReadTimeFirst) {
                const after = item.tutorialReadTime
                if (tutorialReadTime !== after) {
                    tutorialReadTime = item.tutorialReadTimeFirst
                }
            }

            setTimeout(() => {
                minigame = AppMinigame.$refs.minigame

                if (AppMinigame.showConfirmDialog) {
                    confirmLine = AppMinigame.$refs.confirmLine;
                    
                    handleConfirmExpiration()
                } else {
                    cursor = AppMinigame.$refs.cursor;
                    balanceArea = AppMinigame.$refs.balanceArea;
                    fillArea = AppMinigame.$refs.fillArea;
                    tutorialLine = AppMinigame.$refs.tutorialLine;

                    if (doRefsExist()) {
                        minigame.style.background = AppMinigame.visible ? "rgba(0, 0, 0, 0.7)" : rgba(0, 0, 0, 0.0);
                    }

                    handleTutorialReadTime(AppMinigame.visible)

                    setTimeout(() => {
                        minigameState(AppMinigame.visible)
                    }, AppMinigame.visible ? tutorialReadTime : 0);

                    if (item.difficulty !== null) {
                        AppMinigame.difficulty = item.difficulty;
                    }
                }
            }, 0);
        }
    });
};
initMinigame();
