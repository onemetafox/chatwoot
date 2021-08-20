<template>
  <b-form-checkbox v-model="check" name="check-button" switch @change="checked">
    <div class="strip" style="width: 100px;" :style="style">
      <strong v-html="params.value" />
    </div>
  </b-form-checkbox>
</template>
<script>
  import Vue from 'vue';
  import { mapState, mapGetters } from 'vuex';
  export default Vue.extend({
    name: 'lead-status-render',
    data: () => {
      return {
        check: false
      }
    },
    computed: {
      ...mapState({
        wEditID: state => state.enLeads.editID
      }),
      ...mapGetters({
        leadState: 'enLeads/getState'
      }),
      style() {
        let style = ''
        switch(this.params.value) {
          case 'rejected':
            style = 'background: OrangeRed;'
          case 'new':
            style = 'background: Silver;'
          case 'converted':
            style = 'background: Turquoise'
          case 'contacted':
            style = 'background: Lime;'
        }
        return style
      }
    },
    watch: {
      wEditID(newValue, oldValue) {
        this.check = this.params.data.id === newValue
      }
    },
    mounted() {
      this.check = this.params.data.id === this.leadState.editID
    },
    methods: {
      checked(checked) {
        if (checked && this.params.data.id !== this.leadState.editID) 
          this.$store.dispatch('enLeads/show', this.params.data.id).then(res => {
            Promise.all([
              this.$store.dispatch('enLeads/editing', false),
              res
              ? this.$store.dispatch('enLeads/editID', res.id)
              : this.$store.dispatch('enLeads/editID', -1)
            ])
          })
        else if (!checked) 
          Promise.all([
            this.$store.dispatch('enLeads/editing', false),
            this.$store.dispatch('enLeads/editID', -1),
            this.$store.dispatch('enLeads/lead', {})
          ])
      }
    },
  });
</script>
