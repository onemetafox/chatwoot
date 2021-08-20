<template>
  <b-modal id="adGroupsEditModal" hide-footer hide-header-close size='lg' @hide="clearForm">
    <template #modal-title>{{id ? 'Edit Group' : 'Create Group'}}</template>
    <div class="d-block text-center group-edit">
      <ValidationObserver v-slot="{ handleSubmit }">
        <form ref="cf_form" @submit.prevent="handleSubmit(submit)">
          <div class="md-layout create-field-group mt-3">
            <div class="md-layout-item md-medium-size-100 md-xsmall-size-100 md-size-100">
              <ValidationProvider
                name="name"
                :rules="`required|min:${5 || minlen}`"
                v-slot="{ passed, failed }"
              >
                <md-field :class="[{ 'md-error': failed }, { 'md-valid': passed }]">
                  <label>Group name</label>
                  <md-input v-model="name" type="text" />
                  <md-icon class="error" v-show="failed">close</md-icon>
                  <md-icon class="success" v-show="passed">done</md-icon>
                </md-field>
              </ValidationProvider>
            </div>
            <div class="md-layout-item md-medium-size-100 md-xsmall-size-100 md-size-100">
              <multiselect ref="g_select" v-model="ins"
                placeholder="Search user"
                label="username" track-by="id"
                :multiple="true" :taggable="true"
                :options="users"
              />
            </div>
            <md-progress-bar md-mode="indeterminate" v-if="sending" />
            <div class="md-layout">
              <div class="md-layout-item md-medium-size-50 md-xsmall-size-50 md-size-50">
                <md-button type="submit" class="md-success md-raised md-dense" :disabled="sending"
                  v-html="id ? 'update' : 'create'"
                />
              </div>
              <div class="md-layout-item md-medium-size-50 md-xsmall-size-50 md-size-50">
                <md-button class="md-danger md-raised md-dense" :disabled="sending" @click="cancel">cancel</md-button>
              </div>
            </div>
          </div>
        </form>
      </ValidationObserver>
    </div>
  </b-modal>
</template>

<script>
import { mapState} from 'vuex';
import { extend } from "vee-validate";
import { required, min } from "vee-validate/dist/rules";
extend("required", required);
extend("min", min);

export default {
  name: 'ad-tags-edit',
  props: {
    groups: {
      type: Array,
      default: () => []
    },
    users: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      minlen: 5,
      id: null,
      name: null,
      ins: [],
      sending: false,
    };
  },
  computed: {
    ...mapState({
      editID: state => state.adGroups.editID,
    })
  },
  watch: {
    editID(newValue, oldValue) {
      if (newValue !== -1) {
        let group = this.$props.groups.find(k => k.id === newValue)
        if (group) {
          group = JSON.parse(JSON.stringify(group))
          this.id = group.id
          this.name = group.name
          this.ins = group.users.map((u, i)=> {
            return {id: u.id, username: u.username, email: u.email}
          })
        } else {
          this.id = null
          this.name = null
          this.ins = []
        }
        this.$bvModal.show('adGroupsEditModal');
      }
    },
  },
  methods: {
    clearForm() {
      this.$refs.cf_form.reset()
      this.id = null
      this.name = null
      this.ins = []
      this.sending = false
      this.$store.dispatch('adGroups/editID', -1)
    },
    submit() {
      this.sending = true
      let formData = new FormData()
      formData.append('name', this.name)
      if (Array.isArray(this.ins)) {
        let users = this.ins.map((u, i) => {
          return u.id
        })
        formData.append('users', users)
      }
      this.$store.dispatch('adGroups/update', {id: this.id, formData})
      .then(() => {
        Promise.all([
          this.$store.dispatch('adGroups/get'),
          this.$store.dispatch('adUsers/search')
        ]).then(() => {
          let msg = this.id
            ? `Updated a "${this.name}" group..`
            : `Added a new "${this.name}" group..`
          this.$bvModal.hide('adGroupsEditModal');
          this.$store.dispatch('global/setMsg', msg)
        })
      })
    },
    cancel() {
      this.$bvModal.hide('adGroupsEditModal');
    },
  },
};
</script>

<style lang="scss">
</style>
