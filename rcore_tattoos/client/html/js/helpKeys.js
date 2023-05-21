const HELP_KEYS_CLASS = 'help-keys'
const HELP_KEYS_POSITIONS = ['top-left', 'top-right', 'bottom-left', 'bottom-right']; // Also in main.css! 
const HELP_KEYS_DEF_POS = HELP_KEYS_POSITIONS[3];

const AppHelpKeys = new Vue({
    el: '#helpKeysApp',
    data: {
        visible: false,
        classList: {
            HELP_KEYS_CLASS: true
        },
        styleList: false,
        helpKeys: {},
        asColumn: false,
    }
});

function initNuiHelpKeys() {
    function getFormattedPosition(position) {
        if (HELP_KEYS_POSITIONS.includes(position)) {
            return position;
        }

        return HELP_KEYS_DEF_POS;
    }

    window.addEventListener("message", function (event) {
        const item = event.data;
        if (item.type == "helpKeys") {
            AppHelpKeys.visible = item.visible;

            if (item.helpKeys && item.helpKeys.length) {
                AppHelpKeys.helpKeys = item.helpKeys;
            }

            const position = getFormattedPosition(item.position)

            AppHelpKeys.classList = {
                [HELP_KEYS_CLASS]: true,
                [`${HELP_KEYS_CLASS}--column`]: item.asColumn,
                [`${HELP_KEYS_CLASS}--${position}`]: true,
            }

            if (item.marginVertical != undefined || item.marginHorizontal != undefined) {
                AppHelpKeys.styleList = {
                    margin: `${item.marginVertical || 0}vw ${item.marginHorizontal || 0}vw`
                }
            }
        }
    });
};
initNuiHelpKeys();