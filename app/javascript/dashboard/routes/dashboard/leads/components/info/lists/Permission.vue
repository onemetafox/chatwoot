<template>
  <div class="md-layout leads-lists-permission">
    <div v-for="(item, n) in options" :key="`permission-${n}`" class="check--item">
      <b-form-checkbox
        :id="`checkbox-${n}`"
        v-model="item.checked"
        :name="`checkbox-${n}`"
        @change="checked($event,item.id)"
      >
        <p class="check--item--name">{{item.name}}</p>
      </b-form-checkbox>
      <div v-if="item.id === 3 && item.checked">
        <form ref="lead_permission_form">
          <div class="md-layout">
            <multiselect :max-height="150" style="color: black;" v-model="leadState.lead.share_users"
              placeholder="Share Users.."
              label="email" track-by="id"
              :multiple="true" :taggable="true"
              :options="adUserState.users.filter(k => k.id !== leadState.lead.id)"
            />
          </div>
          <div class="md-layout">
            <multiselect :max-height="150" style="color: black;" v-model="leadState.lead.share_groups"
              placeholder="Share Groups.."
              label="name" track-by="id"
              :multiple="true" :taggable="true"
              :options="adGroupState.groups"
            />
          </div>
        </form>
      </div>
    </div>
  </div>
</template>
<script>
  import { mapGetters } from 'vuex';
  export default {
    name: 'leads-lists-permission',
    props: {
      sending: {
        type: Boolean,
        default: false
      }
    },
    data() {
      return {
        options: [
          { id: 1, checked: false, name: 'Keep it private, do not share with others' },
          { id: 2, checked: false, name: 'Share it with everyone' },
          { id: 3, checked: false, name: 'Share it with the following people' },
          { id: 4, checked: false, name: 'Copy campaign permission' }
        ],
      }
    },
    computed: {
      ...mapGetters({
        leadState: 'enLeads/getState',
        adUserState: 'adUsers/getState',
        adGroupState: 'adGroups/getState',
      }),
      wSending: props => props.sending
    },
    watch: {
      wSending(newValue, oldValue) {
        if (newValue) this.$emit('onSubmit', {permission: true})
      }
    },
    methods: {
      checked(checked, id) {
        if (checked) for (const [n, item] of this.options.entries()) item.checked = item.id === id
      }
    },
  };
</script>
<style lang="scss" scoped>
  .leads-lists-permission {
    .check--item {
      width: 100%;
      &--name {
        color: #DD2C00;
      }
    }
    padding: 0 12px;;
  }
</style>
