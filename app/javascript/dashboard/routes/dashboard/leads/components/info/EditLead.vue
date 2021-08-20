<template>
  <woot-modal :show.sync="show" :on-close="onCancel" modal-type="right-aligned">
    <div class="column content-box">
      <woot-modal-header>
        <md-button class="md-primary md-raised md-dense"
        :disabled="sending"
        @click="readySubmit">
          {{leadState.lead.id !== 'new' ? 'Edit Lead' : 'Create Lead'}}
        </md-button>
      </woot-modal-header>
      <md-progress-bar md-mode="indeterminate" v-if="sending" />
      <EditDetails :sending="sending" @onSubmit="onSubmit"/>
    </div>
  </woot-modal>
</template>

<script>
import { mapGetters } from 'vuex';
import EditDetails from './lists';

export default {
  name: 'edit-lead',
  components: {
    EditDetails,
  },
  props: {
    show: {
      type: Boolean,
      default: false,
    },
  },
  data() {
    return {
      sending: false,
    }
  },
  computed: {
    ...mapGetters({
      leadState: 'enLeads/getState',
    }),
  },
  methods: {
    onCancel() {
      let org = this.leadState.leads.find(k => k.id === this.leadState.lead.id)
      if (org)
        Promise.all([
          this.$store.dispatch('enLeads/editing', false),
          this.$store.dispatch('enLeads/lead', org),
          this.$store.dispatch('enLeads/editID', this.leadState.lead.id)
        ])
      else
        Promise.all([
          this.$store.dispatch('enLeads/editing', false),
          this.$store.dispatch('enLeads/lead', {}),
          this.$store.dispatch('enLeads/editID', -1)
        ])
    },
    readySubmit() {
      this.sending = true
      setTimeout(() => {
        this.sending = false
      }, 100)
    },
    async onSubmit(valid) {
      if (valid) {
        console.log('final...', this.leadState.lead)
      }
    }
  },
};
</script>
