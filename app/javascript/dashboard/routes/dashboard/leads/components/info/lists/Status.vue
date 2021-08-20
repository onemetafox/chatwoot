<template>
    <form ref="lead_status_form">
      <div class="md-layout">
        <div class="md-layout-item md-medium-size-33 md-xsmall-size-100 md-size-33">
          <md-field class="field">
            <multiselect :max-height="150" style="color: black;" v-model="leadState.lead.assigned_to"
              placeholder="Assigned to.."
              label="email" track-by="id"
              :multiple="false" :taggable="true"
              :options="adUserState.users.concat([{email: 'Unassigned'}, {id: 'new', email: 'Myself'}]).map(k => {
                if (!k.id && k.id !== 'new' && k.id === leadState.lead.id) k.email = 'Myself'
                return k
              })"
            />
          </md-field>
        </div>
        <div class="md-layout-item md-medium-size-33 md-xsmall-size-100 md-size-33">
          <md-field class="field">
            <multiselect :max-height="150" style="color: black;" v-model="leadState.lead.status"
              placeholder="Status.."
              :multiple="false" :taggable="true"
              :options="status"

            />
          </md-field>
        </div>
        <div class="md-layout-item md-medium-size-33 md-xsmall-size-100 md-size-33">
          <md-field class="field">
            <multiselect :max-height="150" style="color: black;" v-model="leadState.lead.rating"
                placeholder="Rating.."
                label="dom" track-by="id"
                :multiple="false" :taggable="true"
                :options="rating"
              />
          </md-field>
        </div>
      </div>
      <div class="md-layout">
        <div class="md-layout-item md-medium-size-33 md-xsmall-size-100 md-size-33">
          <md-field class="field">
            <multiselect :max-height="150" style="color: black;" v-model="leadState.lead.source"
              placeholder="Source.."
              label="title" track-by="id"
              :multiple="false" :taggable="true"
              :options="source"
              open-direction="top"
            />
          </md-field>
        </div>
        <div class="md-layout-item md-medium-size-33 md-xsmall-size-100 md-size-33">
          <md-field class="field">
            <multiselect :max-height="150" style="color: black;" v-model="leadState.lead.campaign_id"
              placeholder="Campaign.."
              label="name" track-by="id"
              :multiple="false" :taggable="true"
              :options="[]"
              open-direction="top"
            />
          </md-field>
        </div>
      </div>
    </form>
</template>
<script>
  import { mapGetters } from 'vuex';
  export default {
    name: 'leads-lists-status',
    props: {
      sending: {
        type: Boolean,
        default: false
      }
    },
    data() {
      return {
        status: [ 'new', 'contacted', 'converted', 'rejected'],
        rating: [
          {id: 0, dom: '--None--'},
          {id: 1, dom: '★'},
          {id: 2, dom: '★★'},
          {id: 3, dom: '★★★'},
          {id: 4, dom: '★★★★'},
          {id: 5, dom: '★★★★★'},
        ],
        source: [
          {id: 1, title: 'Campaign'},
          {id: 2, title: 'Cold Call'},
          {id: 1, title: 'Online Marketing'},
          {id: 1, title: 'Referral'},
          {id: 1, title: 'Self Generated'},
          {id: 1, title: 'Website'},
          {id: 1, title: 'world of Mouth'},
          {id: 1, title: 'Other'},
        ],
      }
    },
    computed: {
      ...mapGetters({
        leadState: 'enLeads/getState',
        adUserState: 'adUsers/getState'
      }),
      wSending: props => props.sending
    },
    watch: {
      wSending(newValue, oldValue) {
        if (newValue) this.$emit('onSubmit', {status: true})
      }
    }
  };
</script>
<style lang="scss" scoped>
  .field {
    margin: 0;
  }
</style>


