import React, { useState, useEffect } from 'react';
import axios from 'axios';

const FeatureList = () => {
  const [features, setFeatures] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await axios.get('/api/features');
        setFeatures(response.data.data);
        setLoading(false);
      } catch (error) {
        console.error('Error fetching data:', error);
      }
    };
    fetchData();
  }, []);

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div>
      <h1>Feature List</h1>
      <ul>
        {features.map(feature => (
          <li key={feature.id}>
            <p>Atributos</p>
            <p>External ID: {feature.attributes.external_id}</p>
            <p>Magnitude: {feature.attributes.magnitude}</p>
            <p>Title: {feature.attributes.title}</p>
            <p>Place: {feature.attributes.place}</p>
            <p>Time: {feature.attributes.time}</p>
            <p>Tsunami: {feature.attributes.tsunami}</p>
            <p>Mag_type: {feature.attributes.mag_type}</p>
            <p>Longitude: {feature.attributes.coordinates.longitude}</p>
            <p>Latitude: {feature.attributes.coordinates.latitude}</p>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default FeatureList;
