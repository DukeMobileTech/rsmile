<template>
  <div>
    <b-button v-b-toggle.collapse-1 variant="info">
      <b-icon icon="arrows-collapse"></b-icon> Definitions
    </b-button>
    <b-collapse id="collapse-1" class="mt-2">
      <b-card class="mb-1">
        <p class="card-text">
          <strong>Recruited: </strong>
          Number of participants who completed the Consent Form and agreed 
          to participate in the study and were 18+ years old at the time of 
          completing the Contact Info Form.
        </p>
      </b-card>
      <b-card class="mb-1">
        <p class="card-text">
          <strong>Eligible: </strong>
          Number of participants who completed upto the SOGI block of the 
          Baseline Survey and based on their responses to the gender identity 
          questions were put in one of the following 7 sexual gender minority 
          (SGM) groups: <i>non-binary person</i>, <i>transgender woman</i>, 
          <i>transgender man</i>, <i>woman attracted to women</i>, 
          <i>man attracted to men</i>, <i>multi-attracted woman</i>,
          <i>multi-attracted man</i>
        </p>
      </b-card>
      <b-card  class="mb-1">
        <p class="card-text">
          <strong>Ineligible: </strong>
          Number of participants who: completed upto the SOGI block of the
          Baseline Survey and based on their responses to the gender identity 
          questions were categorized as <i>ineligible</i> or <i>no group</i>; 
          or did not progress up to the SOGI block of the Baseline Survey - 
          and their SGM category was automatically marked as <i>blank</i>.
        </p>
      </b-card>
      <b-card class="mb-1">
        <p class="card-text">
          <strong>Derived: </strong>
          Number of participants whose SGM group was marked as one of the ineligible 
          groups, but their responses to the intersex and/or sexual orientation 
          blocks would place them in one of the eligible SGM groups.
        </p>
      </b-card>
      <b-card class="mb-1">
        <p class="card-text">
          <strong>Excluded: </strong>
          Number of participants whose submissions to the study were omitted 
          due to various reasons such as being suspected of fraud, being part 
          of a bot farm, being a test/trainer participant, or were not consented properly.
        </p>
      </b-card>
      <b-card class="mb-1">
        <p class="card-text">
          <strong>Contactable: </strong>
          Number of participants who completed the Baseline Survey up to the 
          Network block and agreed to be contacted later to recruit other 
          participants for the follow-up phases of the study.
        </p>
      </b-card>
      <b-card class="mb-1">
        <p class="card-text">
          <strong>Accepted: </strong>
          Number of participants who completed the Main Section of the short 
          Baseline Survey - up to the Network block, OR completed the original 
          long Baseline Survey in its entirety, and were placed in one of the 
          eligible SGM categories.
        </p>
      </b-card>
    </b-collapse>
  </div>
</template>

<script>
  export default {
    name: 'Definitions',
  };
</script>

<style scoped>
</style>