import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import FeatureList from './FeatureList';
import Comments from './comments';

const App = () => {
  return (
    <Router>
      <div>
        <h1>My React App</h1>
        <Routes>
          <Route path="/api/features" element={<FeatureList />} />
        </Routes>
        <Comments />
      </div>
    </Router>
  );
};

export default App;


