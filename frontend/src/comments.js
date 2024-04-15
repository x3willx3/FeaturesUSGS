import React, { useState } from 'react';
import axios from 'axios';

const Comments = () => {
  const [featureId, setFeatureId] = useState('');
  const [commentBody, setCommentBody] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await axios.post('http://localhost:4567/api/feature/comments', {
        feature_id: featureId,
        body: commentBody
      });
      alert('Comentario creado exitosamente');
    } catch (error) {
      alert('Error al crear el comentario');
      console.error(error);
    }
  };

  return (
    <div>
      <h1>Crear Comentario</h1>
      <form onSubmit={handleSubmit}>
        <div>
          <label>Feature ID:</label>
          <input type="text" value={featureId} onChange={(e) => setFeatureId(e.target.value)} />
        </div>
        <div>
          <label>Comentario:</label>
          <textarea value={commentBody} onChange={(e) => setCommentBody(e.target.value)}></textarea>
        </div>
        <button type="submit">Crear Comentario</button>
      </form>
    </div>
  );
}

export default Comments;
