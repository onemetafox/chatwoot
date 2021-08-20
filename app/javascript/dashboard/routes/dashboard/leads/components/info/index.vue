<template>
  <div class="lead-info">
    <DetailsLead :lead="leadState.lead" />
    <br />
    <b-button-group>
      <b-button pill variant="outline-primary" style="margin-right: 7px;" @click="edit">
        <b-icon icon="pen-fill" variant="primary" />
        Edit
      </b-button>
      <b-button pill variant="outline-danger" @click="del">
        <b-icon icon="trash-fill" variant="danger" />
        Delete
      </b-button>
    </b-button-group>
    <br />
    <b-button-group class="mt-2" v-if="leadState.lead.status !== 'rejected'">
      <b-button pill variant="outline-info" style="margin-right: 7px;"
      @click="changeState('converted')">
        <b-iconstack scale="1">
          <b-icon icon="arrow-repeat" shift-h="-4" variant="primary" />
          <b-icon icon="arrow-repeat" shift-h="0" variant="success" />
          <b-icon icon="arrow-repeat" shift-h="4" variant="danger" />
        </b-iconstack>
        Convert
      </b-button>
      <b-button pill variant="outline-secondary"
      @click="changeState('rejected')">
        <b-iconstack scale="1" rotate="90">
          <b-icon stacked icon="chevron-right" shift-h="-4" variant="danger" />
          <b-icon stacked icon="chevron-right" shift-h="0" variant="success" />
          <b-icon stacked icon="chevron-right" shift-h="4" variant="primary" />
        </b-iconstack>
        Reject
      </b-button>
    </b-button-group>
  </div>
</template>
<script>
import { mapGetters } from 'vuex';
import DetailsLead from './detailsLead.vue';
export default {
  name: 'lead-info',
  components: {
    DetailsLead
  },
  computed: {
     ...mapGetters({
      leadState: 'enLeads/getState'
    }),
  },
  methods: {
    edit() {
      this.$store.dispatch('enLeads/show', this.leadState.editID).then(res => {
        if (res) this.$store.dispatch('enLeads/editing', true)
        else
          Promise.all([
            this.$store.dispatch('enLeads/editID', -1),
            this.$store.dispatch('enLeads/lead', {}),
            this.$store.dispatch('enLeads/editing', false),
            this.$store.dispatch('enLeads/search', this.leadState.query)
          ])
      })
    },
    del() {
      this.$store.dispatch('enLeads/delete', this.leadState.lead.id).then(() => {
        Promise.all([
          this.$store.dispatch('enLeads/editID', -1),
          this.$store.dispatch('enLeads/lead', {}),
          this.$store.dispatch('enLeads/editing', false),
          this.$store.dispatch('enLeads/search', this.leadState.query)
        ])
      })
    },
    changeState(param) {
      if (param === 'rejected')
        this.$store.dispatch('enLeads/status', {id: this.leadState.lead.id, status: param}).then(() => {
          this.$store.dispatch('enLeads/search', this.leadState.query).then(() => {
            let find = this.leadState.leads.find(k=> k.id === this.leadState.lead.id)
            if (find) this.$store.dispatch('enLeads/lead', find)
            else
              Promise.all([
                this.$store.dispatch('enLeads/editID', -1),
                this.$store.dispatch('enLeads/lead', {}),
                this.$store.dispatch('enLeads/editing', false),
              ])
          })
        })
      else if (param === 'converted') {

      }
    },
  },
};
</script>

<style scoped lang="scss">
  .lead-info {
    align-items: flex-start;
    margin-bottom: 1.6rem;
    .user-thumbnail-box {
      margin-right: 1.6rem;
    }
    text-align: center;
  }
</style>
