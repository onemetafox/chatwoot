<template>
    <div class="wizard-body columns content-box small-9">
        <div class="medium-12 columns">
            <page-header :header-title="headerTitle" :header-content="$t('MOONBOARD_SETTINGS.ADD.DESC')" />
        </div>
        <board-dropzone :items="items" class="mb-4"></board-dropzone>
        <board-packery :items="items" :editing="editing"></board-packery>
        <div class="medium-12 columns text-right">
            <router-link class="button success nice" :to="{ name: 'moonboards_list', }">{{ $t('MOONBOARD_SETTINGS.FINISH.BUTTON_TEXT') }}</router-link>
        </div>
    </div>
</template>

<script>

import alertMixin from 'shared/mixins/alertMixin';
import PageHeader from '../../SettingsSubPageHeader';
import boardDropzone from '../BoardDropzone';
import boardPackery from '../components/board-packery'

export default {
    components: {
        PageHeader,
        boardDropzone,
        boardPackery
    },
    mixins: [alertMixin],
    props: {
        moonboard: {
            type: Object,
            default: () => {},
        },
    },

    data() {
        return {
            items: [],
            title: '',
            editing: true
        };
    },

    computed: {
        moonboardId() {
            return this.$route.params.moonboardId;
        },
        headerTitle() {
            return this.$t('MOONBOARD_SETTINGS.ADD.TITLE', {
                MoonboardTitle: this.currentBoard.title,
            });
        },
        currentBoard() {
            return this.$store.getters['moonboards/getMoonboard'](this.moonboardId);
        },
    },
    mounted() { 
    },
    methods: {
    },
};
</script>
