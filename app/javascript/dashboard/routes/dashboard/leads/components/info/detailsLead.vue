<template>
  <div>
    <div class="d-flex justify-content-between align-baseline lead-details">
      <div class="info">
        <div class="title">
          <i class="icon ion-android-person">
            <strong>{{`${lead.first_name} ${lead.last_name}`}}</strong>
          </i>
        </div>
        <md-divider class="md-hr md-theme-demo-light" />
        <div v-for="(item, n) in info" :key="`info-${n}`">
          <i v-if="item.key !== 'status' && item.key !== 'email' && item.key !== 'created_at'" :class="item.icon">
            <strong>{{lead[item.key]}}</strong>
          </i>
          <i v-else-if="item.key === 'status'" :class="item.icon">
            <div class="strip" style="width: 100%;" :style="style">
              <strong>{{lead[item.key]}}</strong>
            </div>
          </i>
          <i v-else-if="item.key === 'email'" :class="item.icon">
            <a :href="`mailto:${lead[item.key]}`">{{lead[item.key]}}</a>
          </i>
          <i v-else :class="item.icon">
            <strong v-html="createdAt" />
          </i>
        </div>
      </div>
      <div class="avatar">
      </div>
    </div>
    <div class="lead-details">
      <div class="title">Summary</div>
      <md-divider class="md-hr md-theme-demo-light" />
      <div v-for="(item, n) in summary" :key="`summary-${n}`"
        class="d-flex justify-content-between align-baseline summary">
        <label>{{`${item.title}:`}}</label>
        <span v-if="item.title === 'Rating'" style="color: orangered">
          <i v-for="i in lead[item.key]" :key="`star--${i}`" class="icon ion-star" />
        </span>
        <strong v-else v-html="lead[item.key]" />
      </div>
      <md-divider class="md-hr md-theme-demo-light" />
    </div>
    <div v-if="social.find(k=> lead[k.key]) ? true : false"
      class="lead-details d-flex justify-content-center" style="height: 25px;">
      <div v-for="(item, n) in social" :key="`social-${n}`" style="width: 30px;">
        <i v-if="lead[item.key] ? true : false" class="social-icon" :class="item.icon" :style="item.style"
          @click="goSocial(lead[item.key])" />
      </div>
    </div>
    <md-divider class="md-hr md-theme-demo-light" />
  </div>
</template>
<script>
  export default {
    name: 'lead-details',
    props: {
      lead: {
        type: Object,
        default: () => {}
      }
    },
    data() {
      return {
        info: [
          {icon: 'icon ion-iphone', key: 'mobile'},
          {icon: 'icon ion-ios-telephone', key: 'phone'},
          {icon: 'icon ion-email', key: 'email'},
          {icon: 'icon ion-social-markdown', key: 'company'},
          {icon: 'icon ion-calendar', key: 'created_at'},
        ],
        summary: [
          {title: 'Status', key: 'status'},
          {title: 'Source', key: 'source'},
          {title: 'Rating', key: 'rating'},
          {title: 'Referred By', key: 'referred_by'},
          {title: 'Assigned By', key: 'assigned_to'},
          {title: 'Campaign', key: 'campaign_id'},
          {title: 'Contact', key: 'contact'},
        ],
        social: [
          {icon: 'icon ion-social-facebook', style: 'color: #1877f2', key: 'facebook'},
          {icon: 'icon ion-social-twitter', style: 'color: #1da1f2;', key: 'twitter'},
          {icon: 'icon ion-social-linkedin', style: 'color: #0a66c2', key: 'linkedin'},
          {icon: 'icon ion-social-skype', style: 'color: #00aff0', key: 'skype'},
        ]
      }
    },
    computed: {
      style() {
        let style = ''
        switch(this.$props.lead.status) {
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
      },
      createdAt() {
        let date = new Date(this.$props.lead.created_at)
        let utc = date.toUTCString().split(' ')
        utc.splice(utc.length-1, 1)
        let time = date.toTimeString().split(' ')
        time.splice(0, 1)
        return utc.concat(time).toString().replace(new RegExp(',,', 'gi'), ',').replace(new RegExp(',', 'gi'), ' ')
      }
    },
    methods: {
      goSocial(link) {
        if (link) {
          alert(link)
        }
      }
    },
  };
</script>
<style lang="scss" scoped>
  .lead-details {
    margin-top: 0.8rem;
    width: 100%;
    .info {
      i {
        color: #D500F9;
      }
      strong {
        color: black;
      }
    }
    .social-icon {
      font-size: 20px;
      cursor: pointer;
    }
    .social-icon:hover {
      font-size: 25px;
    }
  }
  p {
    margin: 0;
  }
</style>
