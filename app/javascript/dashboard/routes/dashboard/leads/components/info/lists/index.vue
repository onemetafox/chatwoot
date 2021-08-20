<template>
  <div>
    <Person :sending="sending" @onSubmit="onSubmit" />
    <div class="edit-details">
      <div class="list">
        <md-list>
          <md-list-item md-expand>
            <span class="md-list-item-text">Status</span>
            <md-list class="md-list-item-content" slot="md-expand">
              <Status :sending="sending" @onSubmit="onSubmit" />
            </md-list>
          </md-list-item>
          <md-list-item md-expand>
            <span class="md-list-item-text">Contact Information</span>
            <md-list class="md-list-item-content" slot="md-expand">
              <Contact :sending="sending" @onSubmit="onSubmit" />
            </md-list>
          </md-list-item>
          <md-list-item md-expand>
            <span class="md-list-item-text">Comment</span>
            <md-list class="md-list-item-content" slot="md-expand">
              <Comment :sending="sending" @onSubmit="onSubmit" />
            </md-list>
          </md-list-item>
          <md-list-item md-expand>
            <span class="md-list-item-text">Web Presence</span>
            <md-list class="md-list-item-content" slot="md-expand">
              <Web :sending="sending" @onSubmit="onSubmit" />
            </md-list>
          </md-list-item>
          <md-list-item md-expand>
            <span class="md-list-item-text">Permission</span>
            <md-list class="md-list-item-content" slot="md-expand">
              <Permission :sending="sending" @onSubmit="onSubmit" />
            </md-list>
          </md-list-item>
        </md-list>
      </div>
    </div>
  </div>
</template>
<script>
  import Person from './Person.vue';
  import Status from './Status.vue';
  import Contact from './Contact.vue';
  import Comment from './Comment.vue'
  import Web from './Web.vue';
  import Permission from './Permission.vue';
  export default {
    name: 'edit-details',
    props: {
      sending: {
        type: Boolean,
        default: false
      }
    },
    data() {
      return {
        valid: {}
      }
    },
    components: {
      Person,
      Status,
      Contact,
      Comment,
      Web,
      Permission
    },
    computed: {
      wSending: props => props.sending
    },
    watch: {
      wSending(newValue, oldValue) {
        if (newValue) 
          setTimeout(() => {
            if (Object.keys(this.valid).length === 6 && Object.values(this.valid).every(k => k))
              this.$emit('onSubmit', true)
            this.valid = {}
          }, 10)
      }
    },
    beforeMount() {
      Promise.all([
        this.$store.dispatch('adUsers/search'),
        this.$store.dispatch('adGroups/get'),
        this.$store.dispatch('adTags/get'),
      ])
    },
    methods: {
      async onSubmit(param) {
        Object.assign(this.valid, param)
      }
    }
  };
</script>
<style lang="scss" scoped>
  @import "~dashboard/assets/scss/md/variables";
  @import "~dashboard/assets/scss/md/mixins";
  @import "~dashboard/assets/scss/md/shadows";
  @import "~dashboard/assets/scss/md/colors";
  @import "~dashboard/assets/scss/md/buttons";
  @import "~dashboard/assets/scss/md/autocomplete";
  @import "~dashboard/assets/scss/md/inputs";
  @import "~dashboard/assets/scss/md/inputs-size";
  @import "~dashboard/assets/scss/md/select";

  .list {
    width: inherit;
  }
  .edit-details > .md-list {
    width: inherit;
    max-width: 100%;
    height: 100%;
    display: inline-block;
    overflow: auto;
    border: 1px solid rgba(#000, .12);
    vertical-align: top;
  }
  .edit-details {
    .md-list-item-text {
      background: #004D40;
      color: white;
    }
  }
</style>
<style type="scss">
  .modal-container form {
    padding: 0 2rem;
  }
  .md-field label {
    color: #42A5F5;
  }
</style>
