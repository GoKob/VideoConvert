<template>
  <div class="home">
    <div class="container">
        <div class="row">
          <video id="video-player" class="mt-3 col-lg-6 col-12"
            autoPlay
            controls
            playsinline
          />
          
          <div class="col-lg-6">
            <div class="row">
              <div class="input-group mb-3 mt-3 col-12">
                <input type="text" v-model="date" class="form-control" placeholder="Please set datetime" aria-label="Load" aria-describedby="Load" required>
                <button class="btn btn-secondary" type="button" id="Load" v-on:click="setplayer">Load</button>
              </div>
              
              <div class="input-group mb-3 col-12">
                <input type="text" v-model="start" class="form-control" placeholder="StartPoint" aria-label="StartPoint" aria-describedby="StartTime" required>
                <button class="btn btn-primary" type="button" id="start" v-on:click="getCurrentTime">Start</button>
              </div>
              
              <div class="input-group mb-3 col-12">
                <input type="text" v-model="end" class="form-control" placeholder="EndPoint" aria-label="EndPoint" aria-describedby="EndTime" required>
                <button class="btn btn-success" type="button" id="end" v-on:click="getCurrentTime">End</button>
              </div>

              <div class="input-group mb-3 col-12">
                <input type="text" v-model="date_folder" class="form-control" placeholder="Date folder" aria-label="DateFolder" aria-describedby="DateFolder" required>
              </div>
              
              <div class="input-group mb-3 col-12">
                <input type="text" v-model="artist_folder" class="form-control" placeholder="Artist folder ID" aria-label="ArtistFolder" aria-describedby="ArtistFolder" required>
              </div>
            </div>
          </div>
        </div>

        <div class="d-grid mt-4 mb-4">
          <button v-bind:class="[activateSubmit == true ? 'btn btn-outline-dark': 'btn btn-dark']" v-bind:disabled="activateSubmit" type="button" v-on:click="requestConvert" >Convert</button>
        </div>
      </div>

    <div class="modal fade" id="Modal" tabindex="-1" aria-labelledby="ModalLabel" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="exampleModalLabel">Request Convert</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body" style="white-space: pre-wrap;" v-text="message" />
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          </div>
        </div>
      </div>
    </div>
    
  </div>
  
</template>

<script>
import { API, Amplify } from 'aws-amplify';
import awsconfig from '../aws-exports';
Amplify.configure(awsconfig);


const player = IVSPlayer.create();

export default {
  props: {
    username: String,
  },
  data(){
    return{
      url: "TEMPLATE_URL",
      date: null,
      start: null,
      end: null,
      date_folder: null,
      artist_folder: null,
      message: ""
    }
  },
  mounted() {
    this.date = this.toISOString(new Date(Date.now() + ((new Date().getTimezoneOffset() + (9 * 60)) * 60 * 1000)));
  },
  computed: {
    activateSubmit() {
      if (this.start == null || this.start == "") {
        return true;
      } else if (this.end == null  || this.end == "") {
        return true;
      } else if (this.date_folder == null || this.date_folder == "") {
        return true;
      } else if (this.artist_folder == null || this.artist_folder == "") {
        return true;
      } else {
        return false;
      }
    }
  },
  methods: {
    setplayer: function() {
      player.attachHTMLVideoElement(document.getElementById('video-player'));
      API.get('requestconvert', '/api/video', {
        queryStringParameters: {
          resource_url: this.url
        }
      })
        .then((response) => {
          player.load(this.url + "master_2.m3u8?start=" + this.date + "&" + response);
          player.play();
        })
        .catch((error) => {
          console.log(error.response);
      });
    },
    getCurrentTime: function(e) {
      console.log(player.core.state.position);
    
      const target = new Date(this.date);
      target.setSeconds(target.getSeconds() + parseInt(player.core.state.position, 10));
      this[e.target.id] = this.toISOString(target);
      
    },
    toISOString: function(date) {
      const month = date.getMonth() + 1;
      
      return date.getFullYear() +
        '-' + ("0"+month).slice(-2) +
        '-' + ("0"+date.getDate()).slice(-2) +
        'T' + ("0"+date.getHours()).slice(-2) +
        ':' + ("0"+date.getMinutes()).slice(-2) +
        ':' + ("0"+date.getSeconds()).slice(-2) + "+09:00";
    },
    requestConvert: async function () {
      const request = {
        headers: {
          "Content-Type": "application/json",
        },
        body: {
          "start": this.start,
          "end": this.end,
          "date_folder": this.date_folder,
          "artist_folder": this.artist_folder
        }
      }
      
      var Modal = new bootstrap.Modal(document.getElementById('Modal'));
      API.post('requestconvert', '/api/convert', request)
        .then((response) => {
          console.log(response);
          this.message = "リクエストに成功しました。結果はGoogle Driveで確認してください";
          Modal.show();
        })
        .catch((error) => {
          console.log(error.response);
          this.message = "リクエストに失敗しました\n\n理由: [" + error.response.data.Reason[0] + "]";
          Modal.show();
        });
    }
    
  }
};
</script>
