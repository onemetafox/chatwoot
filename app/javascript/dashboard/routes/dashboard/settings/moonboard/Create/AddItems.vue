<template>
    <div class="wizard-body columns content-box small-9">
        <div class="medium-12 columns">
            <page-header :header-title="headerTitle" :header-content="$t('MOONBOARD_SETTINGS.ADD.DESC')" />
        </div>
        <board-dropzone :items="items" class="mb-4"></board-dropzone>
        <div class="medium-12 columns text-right">
            <router-link class="button success nice" :to="{ name: 'moonboards_list', }">{{ $t('MOONBOARD_SETTINGS.FINISH.BUTTON_TEXT') }}</router-link>
        </div>
    </div>
</template>

<script>

import alertMixin from 'shared/mixins/alertMixin';
import router from '../../../../index';
import PageHeader from '../../SettingsSubPageHeader';
import boardDropzone from '../BoardDropzone';

export default {
    components: {
        PageHeader,
        boardDropzone
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
            isCreating: false,
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
        async addItems() {
            this.isCreating = true;
            const { moonboardId, selectedAgents } = this;

            try {
                await this.$store.dispatch('moonboardIteams/create', {
                    moonboardId,
                    agentsList: selectedAgents,
                });
                router.replace({
                    name: 'moonboards_finish',
                    params: {
                        page: 'new',
                        moonboardId,
                    },
                });
                this.$store.dispatch('moonboards/get');
            } catch (error) {
                this.showAlert(error.message);
            }
            this.isCreating = false;
        },
    },
};
</script>
