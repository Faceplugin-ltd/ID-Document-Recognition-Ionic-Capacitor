import { IonPage } from '@ionic/react';
import { useHistory } from 'react-router-dom';
import DocumentCapture from '../components/DocumentCapture';
import { goHome } from '../nav';
import { setRecognizeResult } from '../resultStore';

export default function CameraPage() {
  const history = useHistory();

  return (
    <IonPage className="live-page">
      <DocumentCapture
        onCancel={() => goHome(history)}
        onRecognized={(json) => {
          setRecognizeResult(json);
          history.replace('/result');
        }}
      />
    </IonPage>
  );
}
