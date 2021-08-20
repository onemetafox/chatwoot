<template>
  <b-modal id="ceGroupModal"
    hide-footer hide-header-close size='lg'
    @hide="clearForm"
  >
    <template #modal-title>
      {{id ? `#${fieldState.categories[fieldState.selectCatename].find(k => k.id === id).label}# group` : `New group`}}
    </template>
    <div class="d-block text-center group-edit">
      <ValidationObserver v-slot="{ handleSubmit }">
        <form ref="cfg_form" @submit.prevent="handleSubmit(submit)">
          <div class="md-layout ad-fields-edit-group mt-3">
            <div class="md-layout-item md-medium-size-50 md-xsmall-size-50 md-size-50">
              <ValidationProvider
                name="label"
                rules="required|min:3"
                v-slot="{ passed, failed }"
              >
                <md-field :class="[{ 'md-error': failed }, { 'md-valid': passed }]">
                  <label>label *</label>
                  <md-input v-model="label" type="text"> </md-input>
                  <md-icon class="error" v-show="failed">close</md-icon>
                  <md-icon class="success" v-show="passed">done</md-icon>
                </md-field>
              </ValidationProvider>
            </div>
            <div class="md-layout-item md-medium-size-50 md-xsmall-size-50 md-size-50">
              <ValidationProvider
                name="tag"
                rules="required"
                v-slot="{ passed, failed }"
              >
                <md-field :class="[{ 'md-error': failed }, { 'md-valid': passed }]">
                  <!-- <label class="typo__label">
                    <small class="md-color">
                      Restrict by Tag: (Only show fields for accounts that are tagged with the following)
                    </small>
                  </label> -->
                  <md-icon class="error" v-show="failed">close</md-icon>
                  <md-icon class="success" v-show="passed">done</md-icon>
                  <multiselect v-model="tag"
                    placeholder="Search tag"
                    label="name" track-by="id"
                    :multiple="false" :taggable="true"
                    :options="tagState.tags"
                  >
                  </multiselect>
                </md-field>
              </ValidationProvider>
            </div>
            <md-progress-bar md-mode="indeterminate" v-if="sending" />
            <div class="md-layout">
              <div class="md-layout-item md-medium-size-50 md-xsmall-size-50 md-size-50">
                <md-button type="submit" class="md-success md-dense" :disabled="sending">
                  {{id ? `Save this group` : `Create a group`}}
                </md-button>
              </div>
              <div class="md-layout-item md-medium-size-50 md-xsmall-size-50 md-size-50">
                <md-button class="md-danger md-dense" :disabled="sending" @click="cancel">Cancel</md-button>
              </div>
            </div>
          </div>
        </form>
      </ValidationObserver>
    </div>
  </b-modal>
</template>

<script>
import { mapState} from "vuex"
import { extend } from "vee-validate";
import { required, min } from "vee-validate/dist/rules";

extend("required", required);
extend("min", min);

export default {
  name: 'ad-fields-edit-group',
  props: {
    fieldState: {
      type: Object,
      default: () => {}
    },
    tagState: {
      type: Object,
      default: () => {}
    }
  },
  computed: {
    ...mapState({
      ceGroupID: state => state.adFields.ceGroupID
    })
  },
  data() {
    return {
      id: null,
      label: null,
      tag: null,
      sending: false
    };
  },
  watch: {
    ceGroupID(newValue, oldValue) {
      if (newValue !== -1) {
        let seed = this.$props.fieldState.categories[this.$props.fieldState.selectCatename]
        if (Array.isArray(seed)) {
          let find = seed.find(k => k.id === newValue)
          if (find) {
            this.id = find.id
            this.label = find.label
            let tag = this.$props.tagState.tags.find(k => k.id === find.tag_id)
            this.tag = tag ? tag : null
          } else {
            this.id = null
            this.label = null
            this.tag = null
          }
        }
      }
    }
  },

  methods: {
    clearForm() {
      this.id = null
      this.label = null
      this.tag = null
      this.sending = false
      this.$refs.cfg_form.reset();
      this.$store.dispatch('adFields/setCEGroupID', -1)
    },
    submit() {
      this.sending = true
      let formData = new FormData()
      formData.append('klass_name', this.$props.fieldState.selectCatename)
      formData.append('label', this.label)
      formData.append('tag_id', this.tag.id)
      if (this.id) formData.append('name', this.label)
      Promise.all([
        this.id
        ? this.$store.dispatch('adFields/gUpdate', {id: this.id, formData})
        : this.$store.dispatch('adFields/gCreate', formData),
      ]).then(() => {
        Promise.all([
          this.$store.dispatch('adFields/gSearch', this.$props.fieldState.selectCatename),
          this.$store.dispatch('adTags/get')
        ]).then(() => {
          this.$bvModal.hide('ceGroupModal');
        })
      })
    },
    cancel() {
      this.$bvModal.hide('ceGroupModal');
    },
  }
};
</script>

<style lang="scss">
  .md-progress-bar {
    position: absolute;
    top: 0;
    right: 0;
    left: 0;
  }
</style>
