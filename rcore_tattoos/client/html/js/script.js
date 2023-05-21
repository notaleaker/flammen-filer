function close() {
    app.partsMenuVisible = false;
    app.tattoosMenuVisible = false;
    $.post('https://rcore_tattoos/close', JSON.stringify({}));
}

function moveCameraToBodyPart(part) {
    $.post('https://rcore_tattoos/moveCameraToBodyPart', JSON.stringify({
        'part': part
    }));
}

function previewTattoo(currentCategory, tattooName, tattooIdentifier, onlySaveData) {
    $.post('https://rcore_tattoos/previewTattoo', JSON.stringify({
        'currentCategory': currentCategory,
        'tattooName': tattooName,
        'tattooIdentifier': tattooIdentifier,
        'onlySaveData': onlySaveData ? onlySaveData : false,
        'opacity': app.opacity.level,
    }));
}

function resetTattoos() {
    $.post('https://rcore_tattoos/resetPedDecorations', JSON.stringify({}));
}

function postBuyTattoo() {
    $.post('https://rcore_tattoos/buyTattoo', JSON.stringify({
        'useHenna': app.useHenna,
    }));
}

function postRemoveTattoo(name, hash, tattooIdentifier) {
    $.post('https://rcore_tattoos/removeTattoo', JSON.stringify({
        'name': name,
        'hash': hash,
        'identifier': tattooIdentifier,
    }));
}

function postCamSliderValue(value) {
    $.post('https://rcore_tattoos/handleCamSlider', JSON.stringify({
        'value': value
    }));
}

let tattooList;
let purchasePending = false;
let removalPending = false;
let notifBox;

let app = new Vue({
    el: '#app',
    data: {
        visible: false,
        texts: {},
        partsMenuVisible: false,
        tattoosMenuVisible: false,
        tattoos: {},
        parts: {},
        currentCategory: '',
        currentTattooIndex: 0,
        opacity: {
            level: 1,
            price: 0
        },
        useHenna: false,
        hennaPrice: 0,
        onlyPreview: false,
        onlySpecificPart: false,
        isCamSliderInitialized: false,
        waitForEmployee: false,
        search: {
            value: '',
            focus: false,
        },
        listIndexLabel: '',
    },
    methods: {
        initTattooList: function () {
            tattooList = $(this.$refs.tattooList);
        },
        openTattooMenu: function (category) {
            if (!app.tattoos[category].length) return;

            app.currentCategory = category;
            app.partsMenuVisible = false;
            app.tattoosMenuVisible = true;
            app.currentTattooIndex = 0;
            app.search.value = '';

            setTimeout(() => {
                $('.js-tats-menu').show(300);

                const camSlider = $('.js-cam-slider');
                if (camSlider) {
                    camSlider.val(0);
                    if (!this.isCamSliderInitialized) {
                        this.isCamSliderInitialized = true;

                        camSlider.on('input', () => {
                            postCamSliderValue(camSlider.val());
                        });
                    }
                }

                app.initTattooList();
                tattooList.addClass('focused');
                moveCameraToBodyPart(category);
                app.handlePreview();
                app.handleListIndexLabel();
            }, 0);
        },
        closeTattooMenu() {
            app.partsMenuVisible = true;
            app.tattoosMenuVisible = false;
            $('.js-tats-menu').hide(300);

            tattooList.removeClass('focused');
            moveCameraToBodyPart();
            resetTattoos();
        },
        menuGoBackClick: function () {
            if(!purchasePending && !removalPending) {
                this.closeTattooMenu()
            }
        },
        setCurrentTattooIndex: function (e) {
            app.currentTattooIndex = $(e.currentTarget).attr('data-index');
        },
        handlePreview() {
            const currentTat = app.tattoos[app.currentCategory][app.currentTattooIndex];

            if (!currentTat.Owned) {
                previewTattoo(
                    app.currentCategory,
                    currentTat.Name,
                    currentTat.Identifier,
                );
                return true;
            }

            return false;
        },
        buyOrRemoveWithButton() {
            if (tattooList && tattooList.hasClass('focused')) {
                buyTattoo();
            }
        },
        getTattooPriceLabel(price) {
            let label;
            let finalPrice;
            if (price) {
                if (price != '-') {
                    const hennaPrice = app.useHenna ? app.hennaPrice : 0
                    const opacityPrice = (app.opacity.level - 1) * app.opacity.price;
                    finalPrice = (price + hennaPrice + opacityPrice)
                } else {
                    label = '✔'
                }
            }

            if (finalPrice && finalPrice >= 0) {
                label = `${app.texts.currency}${(finalPrice)}`
            } else {
                label = app.texts.free
            }

            return label;
        },
        getTattooName(tattoo) {
            return tattoo.CustomName ? tattoo.CustomName : (tattoo.Name ?? 'Unnamed');
        },
        isMatchingSearch(name) {
            if (!app.search.value.length) {
                return true;
            }

            const isMatching = name.toLowerCase().includes(app.search.value.toLowerCase());

            app.isSearchResult = isMatching;
            return isMatching;
        },
        resetTattooMenu() {
            const firstTattoo = tattooList[0].children[0];
            if(!firstTattoo) {
                this.listIndexLabel = '-/-';
                return;            
            };
            handleSelectingTattoo('click', $(firstTattoo))
        },
        handleListIndexLabel() {
            if (!tattooList) {
                setTimeout(() => {
                    this.handleListIndexLabel();
                }, 100);
                return '-/-';
            }

            if (!this.search.value) {
                this.listIndexLabel = `${app.currentTattooIndex + 1}/${tattooList[0].children.length}`;
                return;
            }

            const list = tattooList[0].children;
            const indexOfSelected = Object.keys(list).find(key => list[key].classList.contains('tat-selected'));

            this.listIndexLabel = `${parseInt(indexOfSelected) + 1}/${tattooList[0].children.length}`;
        },
    },
    watch: {
        'search.value': function() {
            setTimeout(() => {
                this.resetTattooMenu();
            }, 0);
        }
    }
});

$(function () {
    window.addEventListener("message", function (event) {
        const item = event.data;
        if (item.type == "ui") {
            app.visible = item.visible;
            app.partsMenuVisible = item.visible;
        }
        if (item.texts && item.texts.length != 0) {
            app.texts = JSON.parse(item.texts);
        }
        if (item.tattoos && item.tattoos.length != 0) {
            app.tattoos = JSON.parse(item.tattoos);
        }
        if (item.parts && item.parts.length != 0) {
            app.parts = JSON.parse(item.parts);
        }
        if (typeof item.tattooBought !== "undefined" && item.tattooBought !== null) {
            if (item.tattooBought) {
                purchaseSuccessful();
            } else {
                purchasePending = false;
            }
        }
        if (item.removedTattooPrice !== null && Number.isFinite(item.removedTattooPrice)) {
            if (item.removedTattooPrice >= 0) {
                removalSuccessful(item.removedTattooPrice);
            }
            removalPending = false;
        }
        if (item.restartCamSlider !== null && item.restartCamSlider) {
            app.isCamSliderInitialized = false;
        }
        // Notifications
        if (item.type == "notification") {
            addNotification(item.title, item.message, item.style);
        }
        if (typeof item.opacity !== "undefined" && item.opacity !== null) {
            app.opacity.enabled = item.opacity.enabled || false;
            app.opacity.level = Number.isFinite(item.opacity.level) ? item.opacity.level : 1;
            app.opacity.price = Number.isFinite(item.opacity.price) ? item.opacity.price : 0;
        }
        if (item.hennaPrice !== null && Number.isFinite(item.hennaPrice)) {
            app.hennaPrice = item.hennaPrice;
        }

        if (item.closeTattooMenu) {
            app.closeTattooMenu()
        }

        app.onlyPreview = !!item.onlyPreview || !!item.waitForEmployee;

        app.waitForEmployee = !!item.waitForEmployee;

        if (typeof item.openSpecificPart !== 'undefined' && item.openSpecificPart !== false ) {
            if (app.visible && Object.keys(app.tattoos).length) {
                app.onlySpecificPart = true;
                app.openTattooMenu(item.openSpecificPart);
            }
        } else if (item.openSpecificPart === false ){
            app.onlySpecificPart = false;
        }
    });

    const closeKeys = [27, 8];

    $(document.body).bind("keyup", function (key) {
        if (app.visible) {
            if (closeKeys.includes(key.which) && !app.search.focus) {
                if (app.tattoosMenuVisible) {
                    app.closeTattooMenu();
                    return;
                }

                $('.js-tats-menu').hide(300);

                refreshNotifBox()
                if (notifBox) notifBox.innerHTML = "";
                notifBox = false;

                close();
            }

            if (tattooList) {
                if (tattooList.hasClass('focused') && key.which == 13) {
                    key.preventDefault();
                    buyTattoo();
                }
            }
        }
    });

    $(document.body).bind("keydown", function (key) {
        if (app.visible) {
            if (tattooList) {
                if (tattooList.hasClass('focused') && key.which == 40) {
                    key.preventDefault();

                    handleSelectingTattoo('next');
                }

                if (tattooList.hasClass('focused') && key.which == 38) {
                    key.preventDefault();

                    handleSelectingTattoo('prev');
                }
            }
        }
    });

    $(document.body).on("click", '.js-tattoo-item', function (e) {
        handleSelectingTattoo('click', $(e.currentTarget))
    });
});

function handleSelectingTattoo(type, tattoo) {
    if (!tattooList[0].children.length) return;

    if (!purchasePending && !removalPending) {
        const selectedTattoo = tattooList.find('.tat-selected');
        let handledTattoo;

        switch (type) {
            case 'click':
                handledTattoo = tattoo;
                break;
            case 'prev':
                handledTattoo = selectedTattoo.prev();
                break;
            case 'next':
                handledTattoo = selectedTattoo.next();
                break;
        }

        if (handledTattoo.is('li')) {
            if (selectedTattoo == handledTattoo) return;

            selectedTattoo.removeClass('tat-selected');
            handledTattoo.addClass('tat-selected');
            handledTattoo.get(0).scrollIntoViewIfNeeded();
            app.currentTattooIndex = parseInt(handledTattoo.attr('data-index'));

            if (!app.handlePreview()) {
                resetTattoos();
            }

        }
        app.handleListIndexLabel();
    }
}

let lastBoughtTattoo;
let buyTattooDebounce = false;

function buyTattoo() {
    if (app.search.focus) {
        return;
    }
    
    if (!tattooList[0].children.length) return;

    if (app.waitForEmployee) {
        const dialog = app.$refs.waitForEmployeeDialog;

        if (dialog) {
            dialog.classList.remove('menu__dialog--anim');
            setTimeout(() => {
                dialog.classList.add('menu__dialog--anim');
            }, 0);
        }
    }

    if (!buyTattooDebounce && app.tattoosMenuVisible && !purchasePending && !app.onlyPreview) {
        buyTattooDebounce = true;
        setTimeout(() => {buyTattooDebounce = false}, 200)

        const currentTat = app.tattoos[app.currentCategory][app.currentTattooIndex];
        if (currentTat.Owned == false) {
            purchasePending = true;
            lastBoughtTattoo = tattooList.find('.tat-selected');
            postBuyTattoo();
        } else {
            removalPending = true;
            postRemoveTattoo(
                currentTat.Name,
                currentTat.Name,
                currentTat.Identifier,
            );
            previewTattoo(
                app.currentCategory,
                currentTat.Name,
                currentTat.Identifier,
                true
            );
        }
    }
}

function purchaseSuccessful() {
    if (lastBoughtTattoo) {
        lastBoughtTattoo.find('.js-tattoo-price').text('✔');
        app.tattoos[app.currentCategory][app.currentTattooIndex].Owned = true;
        purchasePending = false;
    }
}

function removalSuccessful(price) {
    price = price === 0 ? app.texts.free : app.texts.currency + price;
    tattooList.find('.tat-selected').find('.js-tattoo-price').text(price);
    app.tattoos[app.currentCategory][app.currentTattooIndex].Owned = false;
}

let notifId = 0
function addNotification(title, msg, style) {
    refreshNotifBox()

    const notif = 
        `<div class="notif-box__notif ` +
            `notif-box__notif--` +
                style +
            `" id="` + notifId + `">` + 
            `<span class="notif-box__title">` +
                title +
            `</span>` +
            `<span class="notif-box__msg">` +
                msg +
            `</span>` +
        `</div>`;
    notifBox.prepend(notif);
    
    const thisNotifId = notifId++;

    setTimeout(() => {
        refreshNotifBox()
        if(notifBox) {
            notifBox.find('#' + thisNotifId).remove();
        }
    }, 7000);
}

function refreshNotifBox() {
    if (!notifBox || notifBox.length <= 0) notifBox = $('.js-notif');
}