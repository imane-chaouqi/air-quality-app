const mongoose = require('mongoose');

const measureSchema = new mongoose.Schema({
  temperature: {
    type: Number,
    required: true,
    min: -40, // Plage physique réelle du DHT22
    max: 80
  },
  humidity: {
    type: Number,
    required: true,
    min: 0,
    max: 100
  },
  pm25: {
    type: Number,
    required: true,
    min: 0, // Plage physique du PMS5003
    max: 1000
  },
  pm10: {
    type: Number,
    required: true,
    min: 0,
    max: 1000
  },
  isSimulated: {
    type: Boolean,
    default: false
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Measure', measureSchema);