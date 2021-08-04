<template>
  <div class="post-div">
    {{ /* HEADER */}}
    <div class="header-wrap">
      <div class="header">
        <h5 class="block-title">
          <i class="share-post-icon ion-share"></i>
          {{ $t('SIDEBAR.POSTS') }}
        </h5>
      </div>
    </div>
    {{ /* Form */}}
    <form-wizard
      class="step-form-wizard wizard-body columns content-box"
      title=""
      subtitle=""
      color="#47A7F6"
      shape="tab"
      @on-complete="onSubmit"
    >
      <tab-content title="Post Details" :before-change="validatePostDetails">
        <form class="row">
          <div class="medium-12 columns">
            <label>
              Title
              <input
                v-model="form.title"
                type="text"
                placeholder="Enter title"
                required
              />
            </label>
            <span v-if="error.title" class="post-form-warning">Title is required</span>
          </div>
          <div class="medium-12 columns">
            <label>
              Description
              <textarea
                v-model="form.description"
                rows="5"
                placeholder="Enter description"
                required
              ></textarea>
            </label>
            <span v-if="error.description" class="post-form-warning">Description is required</span>
          </div>
        </form>
      </tab-content>
      <tab-content title="Social Platforms" :before-change="validateSocialPlatform">
        <div class="columns channel">
          <button v-for='(socialPlatform) in socialIconsPath' class='social-btn' :class='{selected_platform : form.social_platform === socialPlatform.name}' @click='selectSocialPlatform(socialPlatform.name)'>
            <img
              :id="socialPlatform.name"
              class="social-paltform-icons"
              :src="socialPlatform.path"
            />
          </button>
        </div>
      </tab-content>
      <tab-content title="Upload" :before-change="validateUpload">
        <div class="pull-right">
          <multiselect
            v-model="selectedUploadOption"
            track-by="name"
            label="name"
            :placeholder="$t('FORMS.MULTISELECT.SELECT_ONE')"
            selected-label
            :select-label="$t('FORMS.MULTISELECT.ENTER_TO_SELECT')"
            :deselect-label="$t('FORMS.MULTISELECT.ENTER_TO_REMOVE')"
            :options="customOptions"
            :searchable="false"
            :allow-empty="true"
          />
        </div>
        <div v-if="showActionLinkDiv" class="medium-12 columns">
          <label>
            <input
              v-model="form.action_link"
              type="url"
              placeholder="Enter action link"
              required
              @blur="validateURL"
            />
          </label>
          <span v-if="error.action_link" class="post-form-warning">{{error.action_link}}</span>
        </div>
        <div v-if="showImageUploadDiv">
          <div class="file-dropzone">
            <input
              type="file"
              accept="image/*"
              class="input-file"
              ref="image_input"
              :multiple="this.form.social_platform !== 'instagram'"
              @change="getImages()"
              @click="selectImages = []"
            />
            <p v-if="!uploading_image" class="dropzone-text click-upload-text">Click to upload image or drop image here</p>
            <p v-if="uploading_image" class="dropzone-text uploading-block"><img src='~dashboard/assets/images/buffering-circles.gif'/><strong>Uploading Please Wait...</strong></p>
          </div>
          <span v-if="error.image_error" class="post-form-warning">{{error.image_error}}</span>
          <div class='row preview-image-row'>
            <div class='column preview-image-column' v-for='(file, index) in form.images'>
              <div class="image-close-icon" @click="removeImageFromArray(index)"><i class="remove-image-icon ion-close-circled"></i></div>
              <img :src='file' />
            </div>
          </div>
        </div>
        <div v-if="showVideoUploadDiv">
          <div class='file-dropzone'>
            <input
              type="file"
              accept="video/*"
              class="input-file"
              ref="video_input"
              @change="getVideos()"
            />
            <p v-if="!uploading_video" class="dropzone-text click-upload-text">Click to upload video or drop video here</p>
            <p v-if="uploading_video" class="dropzone-text uploading-block"><img src='~dashboard/assets/images/buffering-circles.gif'/><strong>Uploading Please Wait...</strong></p>
          </div>
          <span v-if="error.video_error" class="post-form-warning">{{error.video_error}}</span>
          <div v-if="form.video_url" class="row preview-image-row">
            <div class="column preview-image-column">
              <div class="image-close-icon" @click="removeVideo"><i class="remove-image-icon ion-close-circled"></i></div>
              <video width="450" controls :src="form.video_url"></video>
            </div>
          </div>
        </div>
        <span v-if="error.action_media_error" class="post-form-warning">{{error.action_media_error}}</span>
      </tab-content>
      <tab-content title="Schedule">
        <div class='schedule-dialogue'>
          <p>Do you want to schedule this post?</p><input type="checkbox" id="schedule-post" class="schedule-checkbox" v-model='allow_schedule'>
        </div>
        <div v-if='allow_schedule' class="row schedule-date-section">
          <div class="medium-12 columns">
            <section class='date-picker'>
              <p class='date-picker-dialogue'>Select Date and Time:</p>
              <VueCtkDateTimePicker class='date-and-time-picker' :color='datePickerOptions.color' :label='datePickerOptions.label' :format='datePickerOptions.format' :min-date ="datePickerOptions.minimumDate" v-model='form.scheduled_at'></VueCtkDateTimePicker>
            </section>
          </div>
        </div>
      </tab-content>
    </form-wizard>
  </div>
</template>

<script>
import { FormWizard, TabContent } from 'vue-form-wizard';
import 'vue-form-wizard/dist/vue-form-wizard.min.css';
import VueCtkDateTimePicker from 'vue-ctk-date-time-picker';
import 'vue-ctk-date-time-picker/dist/vue-ctk-date-time-picker.css';
import S3 from 'aws-s3';
import postShare from '../../../../api/postShare';


export default {
  name: 'Index',
  components: {
    FormWizard,
    TabContent,
    VueCtkDateTimePicker,
  },
  data() {
    return {
      form: {
        title: null,
        description: null,
        post_type: null,
        images: [],
        video_url: null,
        action_link: null,
        social_platform: null,
        scheduled_at: null,
      },
      socialIconsPath: [
        {
          name: 'facebook',
          path: require('dashboard/assets/images/channels/facebook.png'),
        },
        {
          name: 'instagram',
          path: require('dashboard/assets/images/channels/instagram-logo.png'),
        },
        {
          name: 'twitter',
          path: require('dashboard/assets/images/channels/twitter.png'),
        },
      ],
      uploadOptions: [
        {
          id: 0,
          name: 'Simple Text',
        },
        {
          id: 1,
          name: 'Call to Action',
        },
        {
          id: 2,
          name: 'Upload Image',
        },
        {
          id: 3,
          name: 'Upload Video',
        },
      ],
      datePickerOptions: {
        minimumDate: null,
        color: '#47A7F6',
        label: '',
        format: 'YYYY-MM-DD HH:mm',
      },
      allow_schedule: false,
      selectedUploadOption: null,
      error: {},
      showActionLinkDiv: false,
      showImageUploadDiv: false,
      showVideoUploadDiv: false,
      selectImages: [],
      selectVideo: null,
      uploading_image: false,
      uploading_video: false,
    };
  },
  created() {
    let d = new Date();
    this.datePickerOptions.minimumDate = `${d.getFullYear()}-${d.getMonth()+1}-${d.getDate()} ${d.getHours()}:${d.getMinutes()}`;
  },
  computed: {
    customOptions() {
      return this.uploadOptions.filter(data => {
        if (this.form.social_platform === 'facebook') {
          return data;
        } else if (this.form.social_platform === 'twitter') {
          if (data.id !== 1) return data;
        } else if (this.form.social_platform === 'instagram') {
          if (data.id !== 0 && data.id !== 1) return data;
        }
      });
    }
  },
  watch: {
    selectedUploadOption() {
      this.error = {};
      if (this.selectedUploadOption.id === 0) {
        this.form.post_type = 'text';
        this.showActionLinkDiv = false;
        this.showImageUploadDiv = false;
        this.showVideoUploadDiv = false;
      } else if (this.selectedUploadOption.id === 1) {
        this.form.post_type = 'action_link';
        this.showActionLinkDiv = true;
        this.showImageUploadDiv = true;
        this.showVideoUploadDiv = true;
      } else if (this.selectedUploadOption.id === 2) {
        this.form.post_type = 'image_post';
        this.showActionLinkDiv = false;
        this.showImageUploadDiv = true;
        this.showVideoUploadDiv = false;
      } else if (this.selectedUploadOption.id === 3) {
        this.form.post_type = 'video_post';
        this.showActionLinkDiv = false;
        this.showImageUploadDiv = false;
        this.showVideoUploadDiv = true;
      }
    },
  },
  methods: {
    getFileImage(data) {
      return URL.createObjectURL(data);
    },
    validatePostDetails() {
      this.error = {};
      if (!this.form.title || this.form.title.replace(/\s/g, '').length === 0)
        this.error.title = 'Title field is required';
      if (!this.form.description || this.form.description.replace(' ', '').length === 0)
        this.error.description = 'Description field is required';
      return !this.error.title && !this.error.description;
    },
    validateURL() {
      this.error = {};
      if(this.form.action_link && this.form.action_link.length > 0) {
        let valid_url = /[a-z0-9-\.]+\.[a-z]{2,4}\/?([^\s<>\#%"\,\{\}\\|\\\^\[\]`]+)?$/.test(this.form.action_link);
        if (!valid_url)
          this.error.action_link = 'Link is not valid';
      }else
        this.error.action_link = 'Action link is required';
    },
    validateUpload() {
      this.error = {};
      if (this.form.post_type === 'action_link') {
        if (!this.form.action_link)
          this.error.action_link = 'Action link is required';
        if(!this.uploading_image && !this.uploading_video) {
          if (this.form.images.length === 0 && !this.form.video_url)
            this.error.action_media_error = 'Images or Videos are required';
        }
        return !this.error.action_link && !this.error.action_media_error && !this.uploading_image && !this.uploading_video;
      } else if (this.form.post_type === 'image_post') {
        if(!this.uploading_image) {
          if (this.form.images.length === 0)
            this.error.image_error = 'Images are required';
        }
        return !this.error.image_error && !this.uploading_image;
      } else if (this.form.post_type === 'video_post') {
        if(!this.uploading_video) {
          if (!this.form.video_url)
            this.error.video_error = 'Video is required';
        }
        return !this.error.video_error && !this.uploading_video;
      } else return true;
    },
    validateSocialPlatform() {
      return this.form.social_platform !== null;
    },
    removeImageFromArray(index) {
      this.form.images.splice(index, 1);
    },
    removeVideo() {
      this.form.video_url = null;
      this.selectVideo = null;
    },
    async onSubmit() {
      try {
        console.log('DATA : ', JSON.stringify({social_media_posts: this.form }, null, 4));
        await postShare.create({social_media_posts: this.form });
        bus.$emit('newToastMessage', this.allow_schedule ? `Post scheduled successfully for the ${this.form.social_platform}` : `Posted successfully on the ${this.form.social_platform}`);
        setTimeout(() => this.$router.go(0), 2000);
      } catch (error) {
        bus.$emit('newToastMessage', error.message);
      }
    },
    async getImages() {
      this.error = {};
      if(this.form.social_platform === 'instagram') {
        this.form.images = [];
        this.selectImages = [];
      }
      if (this.$refs.image_input.files.length < 9) {
        this.$refs.image_input.files.forEach(file => this.selectImages.push(file));
        let imageDirName = `chatwoot_test/images`;
        const _S3 = new S3({
          bucketName: 'southville-solutions',
          dirName: imageDirName,
          region: process.env.AWS_REGION,
          accessKeyId: process.env.AWS_ACCESS_KEY,
          secretAccessKey: process.env.AWS_SECRETE_KEY,
        });
        this.uploading_image = true;
        for (let i = 0; i < this.selectImages.length; i++) {
          let checkImageExist = false;
          let imageName = this.selectImages[i].name.replace(/\s/g, '');
          this.form.images.forEach(img => checkImageExist = img.includes(imageName));
          if(!checkImageExist) {
            let fileName = `${Date.now()}_${imageName}`.split('.')[0];
            try {
              const data = await _S3.uploadFile(this.selectImages[i], fileName);
              this.form.images.push(data.location);
            } catch (error) {
              this.error.image_error = `Image not uploaded`;
            }
          }
        }
        this.uploading_image = false;
      }else{
        this.error.image_error = 'You can upload upto 8 images';
      }
    },
    async getVideos(){
      this.selectVideo = this.$refs.video_input.files[0];
      let videoDirName = `chatwoot_test/videos`;
      const _S3 = new S3({
        bucketName: 'southville-solutions',
        dirName: videoDirName,
        region: process.env.AWS_REGION,
        accessKeyId: process.env.AWS_ACCESS_KEY,
        secretAccessKey: process.env.AWS_SECRETE_KEY,
      });
      this.uploading_video = true;
      let fileName = `${Date.now()}_${this.selectVideo.name.replace(/\s/g, '')}`.split('.')[0];
      try {
        const data = await _S3.uploadFile(this.selectVideo, fileName);
        this.form.video_url = data.location;
      } catch (error) {
        this.error.video_error = `Video not uploaded`;
      }
      this.uploading_video = false;
    },
    selectSocialPlatform(data) {
      this.form.social_platform = data;
    },
  },
};
</script>

<style lang="scss">
.post-div {
  width: 100%;
  text-align: center;
  .step-form-wizard {
    display: inline-block;
    width: 55%;
    height: calc(100% - 50px);
  }
  .step-form-wizard::-webkit-scrollbar {
    width: 0;
    background: transparent;
  }
}
.header-wrap {
  width: 100%;
  height: 55px;
  padding: var(--space-normal);
  border-bottom: #eeeeee solid 1px;
  .block-title {
    float: left;
    font-size: 2.4rem;
    margin-top: -4px;
    margin-bottom: -9px;
    .share-post-icon {
      margin-right: 6px;
    }
  }
}
.post-form-warning {
  color: red;
}
.wizard-progress-with-circle {
  display: none;
}
.wizard-icon-circle.md.tab_shape {
  display: none !important;
}
.wizard-icon-container.tab_shape {
  display: none !important;
}
.wizard-navigation {
  .wizard-nav-pills {
    li {
      a {
        span {
          height: 0px !important;
        }
      }
    }
    .active {
      background-color: #47A7F6;
      height: 30px;
      padding: 2px;
      border-radius: 6px;
      a {
        span {
          color: white !important;
        }
      }
    }
  }
}

.social-paltform-icons {
  width: 75px;
  margin: 10px;
}

.file-dropzone {
  height: 150px;
  margin-top: 10px;
  min-height: 150px;
  padding: 10px 10px;
  position: relative;
  cursor: pointer;
  outline: 2px dashed grey;
  outline-offset: -10px;
  background: lightcyan;
  color: dimgrey;
  .input-file {
    opacity: 0;
    width: 100%;
    height: 150px;
    cursor: pointer;
  }
  .dropzone-text {
    font-size: 2.0rem;
    text-align: center;
    margin-top: -162px;
  }
  .click-upload-text {
    padding: 45px 0;
  }
  .uploading-block {
    padding: 30px 0;
    img {
      width: 60px;
    }
  }
}
.file-dropzone:hover {
  background: lightblue;
}
.preview-image-row {
  display: flex;
  .preview-image-column {
    flex: 33.33%;
    padding: 5px;
    img {
      width: 145px;
      height: 150px;
    }
    .image-close-icon {
      width: 20px;
      margin-top: 3px;
      margin-bottom: 8px;
      position: relative;
      z-index: 1;
      .remove-image-icon {
        font-size: 2.0rem;
        color: #EF4B46;
        cursor: pointer;
      }
    }
    .progress-bar {
      margin-left: 29px;
    }
  }
}
.social-btn {
  margin: 20px;
  cursor: pointer;
}
.selected_platform {
  background: #c6d8e8;
  border-radius: 20px;
}
.schedule-dialogue {
  display: flex;
  .schedule-checkbox {
    margin: 0px 10px;
    width: 28px;
    height: 17px;
  }
}
.mx-icon-calendar {
  margin-top: -10px;
}
.schedule-date-section {
  display: flex;
  margin-top: 15px;
  .date-picker {
    display: flex;
    .date-picker-dialogue {
      width: 202px;
      margin-top: 7px;
      margin-left: -7px;
      margin-right: 10px;
    }
  }
}
.field.has-value:not(.no-label) .field-input[data-v-5b500588]{
  padding-top: 7px;
}
.field.has-value:not(.no-label) .custom-button {
  margin-top: 9px;
}
</style>
