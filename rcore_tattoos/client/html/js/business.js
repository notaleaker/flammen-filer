let index = 0;

// NUI Posts
function chooseMenuValue(identifier, message) {
    $.post('https://rcore_tattoos/menuapi_inputmethod', JSON.stringify({
        identifier: identifier,
        message: message,
    }));
}

function closeMenu(identifier, message) {
    $.post('https://rcore_tattoos/menuapi_close', JSON.stringify({
        identifier: identifier,
        message: message,
    }));
}

// Inputs
const validInputTypes = ['inputDeposit', 'inputWithdraw'];

const AppMargin = new Vue({
    el: '#marginMenu',
    data: {
        identifier: null,
        titleMenu: "rcore",
        float: "middle_screen",
        position: "middle_screen",
        ChooseText: "Accept",
        CloseText: "Close",
        visible: false,
        marginData: {
            min: 0,
            max: 100,
            current: 20,
        },
        inputType: null,
        texts: {
            example: 'Example',
            price: 'Price',
            newPrice: 'New Price',
            profit: 'Profit',
            currency: '$',
        },
    },
    methods: {
        Choose: function () {
            chooseMenuValue(this.identifier, this.marginData.current)
        },
        Close: function () {
            closeMenu(this.identifier, this.inputType)
        },
    },
});

const App = new Vue({
    el: '#menu',
    data: {
        identifier: null,
        titleMenu: "rcore",
        float: "left",
        position: "middle",
        visible: false,
        menu: [],
        businessMoney: '0$',
    },
});

const AppInput = new Vue({
    el: '#inputMenu',
    data: {
        identifier: null,
        titleMenu: "rcore",
        float: "middle_screen",
        position: "middle_screen",
        ChooseText: "Accept",
        CloseText: "Close",
        visible: false,
        maxValue: 0,
        value: 0,
        texts: {
            title: 'Input',
            currency: '$',
        },
        description: "",
        inputType: 'input',
    },
    methods: {
        Choose: function () {
            chooseMenuValue(this.identifier, this.value)
        },
        Close: function () {
            closeMenu(this.identifier, this.inputType)
        },
        validate: function () {
            const val = this.value;

            if (validInputTypes.includes(this.inputType)) {
                let num = parseInt(val)
                const balance = this.maxValue;

                if (isNaN(num) || num < 0) {
                    num = 0
                }
                else if (num > balance) {
                    num = balance
                }

                this.value = num
            }
        },
        inputFocus: function () {
            setTimeout(() => {
                const input = this.$refs.input

                if (input && input instanceof Element) {
                    input.focus();
                }
            }, 0);
        }
    },
});

function setActiveMenuIndex(index, active_) {
    for (let i = 0; i < App.menu.length; i++) {
        App.menu[i].active = false
    }
    if (App.menu[index] != null) App.menu[index].active = active_
}

// Menu
$(function () {
    function display(bool) {
        App.visible = bool;
    }
    window.addEventListener('message', function (event) {
        const item = event.data;

        if (item.type === "tattoos_menu_reset") {
            App.menu = [];
        }

        if (item.type === "tattoos_menu_add") {
            App.menu.push({
                label: item.label,
                number: item.index,
                active: false,
            });
        }

        if (item.type === "tattoos_menu_title") {
            App.titleMenu = item.title
        }

        if (item.type === "tattoos_menu_ui") {
            display(item.status);
            if (item.properties) {
                App.float = item.properties.float;
                App.position = item.properties.position;
            }
            App.identifier = item.identifier;
            index = 0;
            setActiveMenuIndex(0, true)
        }

        if (App.visible && !AppMargin.visible && !AppInput.visible) {
            if (item.type === "tattoos_menu_enter") {
                $.post('https://rcore_tattoos/menuapi_clickItem', JSON.stringify({
                    index: App.menu[index].number,
                    identifier: App.identifier,
                }));
            }

            if (item.type === "tattoos_menu_up") {
                const lastIndex = index;
                index--;
                if (index < 0) {
                    index = App.menu.length - 1
                    document.getElementById('scrolldiv').scrollTop = 90000;
                } else {
                    document.getElementById('scrolldiv').scrollTop -= 33;
                }
                setActiveMenuIndex(index, true)

                $.post('https://rcore_tattoos/menuapi_selectNew', JSON.stringify({
                    index: App.menu[index].number,
                    identifier: App.identifier,
                    newIndex: App.menu[index].number,
                    oldIndex: App.menu[lastIndex].number,
                }));
            }

            if (item.type === "tattoos_menu_down") {
                const lastIndex = index;
                index++;
                if (index > App.menu.length - 1) {
                    index = 0
                    document.getElementById('scrolldiv').scrollTop = 0;
                } else {
                    document.getElementById('scrolldiv').scrollTop += 33;
                }

                setActiveMenuIndex(index, true)

                $.post('https://rcore_tattoos/menuapi_selectNew', JSON.stringify({
                    index: App.menu[index].number,
                    identifier: App.identifier,
                    newIndex: App.menu[index].number,
                    oldIndex: App.menu[lastIndex].number,
                }));
            }
        }
    })
});

// MarginMenu
$(function () {
    function display(bool) {
        AppMargin.visible = bool;
    }
    window.addEventListener('message', function (event) {
        const item = event.data;

        // Business money data
        if (item.type === "business_money_menu_data") {
            App.businessMoney = `${item.businessMoney || 0} ${item.currency || "$"}`;
        }

        // Handling margin data
        if (item.type === "margin_menu_data") {
            if (item.marginData) {
                AppMargin.marginData = item.marginData;
            }

            if (item.texts && item.texts.length != 0) {
                AppMargin.texts = JSON.parse(item.texts);
            }
        }

        // Return if input type is invalid
        if (item.inputType !== 'margin') return;
        AppMargin.inputType = item.inputType;

        // MenuAPI Data
        if (item.type === "tattoos_menu_title_input") {
            AppMargin.titleMenu = item.title
        }

        if (item.type === "tattoos_menu_ui_input") {
            display(item.status);
            if (item.properties) {
                AppMargin.float = item.properties.float;
                AppMargin.position = item.properties.position;
                AppMargin.ChooseText = item.properties.ChooseText;
                AppMargin.CloseText = item.properties.CloseText;
            }
            AppMargin.identifier = item.identifier;
        }
    })
});

// InputMenu
$(function () {
    function display(bool) {
        AppInput.visible = bool;

        if (AppInput.visible) {
            AppInput.value = 0;
            AppInput.validate();
            AppInput.inputFocus();
        }
    }
    window.addEventListener('message', function (event) {
        const item = event.data;

        // Handling max input value (usually current money of player/business) 
        if (item.type === "tattoos_input_menu_data") {
            if (item.maxValue !== undefined) {
                AppInput.maxValue = item.maxValue;
            }
        }
        
        // Handling translations
        if (item.texts && item.texts.length != 0) {
            AppInput.texts = JSON.parse(item.texts);

            AppInput.description = `${AppInput.maxValue} ${AppInput.texts.currency || ""}`
        }

        // Return if type is invalid
        if (!validInputTypes.includes(item.inputType)) return;
        AppInput.inputType = item.inputType;

        // MenuAPI data
        if (item.type === "tattoos_menu_title_input") {
            AppInput.titleMenu = item.title;
        }

        if (item.type === "tattoos_menu_ui_input" && item.inputType) {
            display(item.status);
            if (item.properties) {
                AppInput.float = item.properties.float;
                AppInput.position = item.properties.position;
                AppInput.ChooseText = item.properties.ChooseText;
                AppInput.CloseText = item.properties.CloseText;
            }
            AppInput.identifier = item.identifier;
        }
    })
});