const express = require('express');
const router = express.Router();
const { 
    getDestinations, 
    getDestinationById, 
    getPopularDestinations,
    getSchedulesByDestination 
} = require('../controllers/destinationController');

router.get('/', getDestinations);
router.get('/popular', getPopularDestinations);
router.get('/:id', getDestinationById);
router.get('/:id/schedules', getSchedulesByDestination);

module.exports = router;