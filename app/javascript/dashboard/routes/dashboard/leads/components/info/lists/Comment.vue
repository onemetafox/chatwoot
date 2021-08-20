<template>
  <b-form-textarea
    v-model="leadState.lead.comment"
    placeholder="Enter something..."
    rows="3"
    max-rows="6"
  />
</template>
<script>
  import { mapGetters } from 'vuex';
  export default {
    name: 'leads-lists-comment',
    props: {
      sending: {
        type: Boolean,
        default: false
      }
    },
    computed: {
      ...mapGetters({
        leadState: 'enLeads/getState',
      }),
      wSending: props => props.sending
    },
    watch: {
      wSending(newValue, oldValue) {
        if (newValue) this.$emit('onSubmit', {comment: true})
      }
    }
  };
</script>
