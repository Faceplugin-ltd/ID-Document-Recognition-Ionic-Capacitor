import { useState } from 'react';
import {
  IonBackButton,
  IonButton,
  IonButtons,
  IonContent,
  IonHeader,
  IonPage,
  IonSpinner,
  IonTitle,
  IonToolbar,
} from '@ionic/react';
import { recognize } from 'document-reader-capacitor';
import { useHistory } from 'react-router-dom';
import { displayUri, pickGalleryPhoto } from '../pickImage';
import { setRecognizeResult } from '../resultStore';

export default function Gallery() {
  const history = useHistory();
  const [front, setFront] = useState<string | null>(null);
  const [back, setBack] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');

  const pick = async (side: 'front' | 'back') => {
    setError('');
    try {
      const uri = await pickGalleryPhoto();
      if (side === 'front') setFront(uri);
      else setBack(uri);
    } catch (e: unknown) {
      setError(e instanceof Error ? e.message : String(e));
    }
  };

  const onRecognize = async () => {
    if (!front || busy) return;
    setBusy(true);
    setError('');
    try {
      const json = await recognize(front, back);
      setRecognizeResult(json);
      history.replace('/result');
    } catch (e: unknown) {
      setError(e instanceof Error ? e.message : String(e));
    } finally {
      setBusy(false);
    }
  };

  return (
    <IonPage>
      <IonHeader>
        <IonToolbar>
          <IonButtons slot="start">
            <IonBackButton defaultHref="/home" />
          </IonButtons>
          <IonTitle>Gallery</IonTitle>
        </IonToolbar>
      </IonHeader>
      <IonContent className="ion-padding">
        <p className="muted">
          Front image is required. Back is optional (ID cards).
        </p>
        <div className="gallery-row">
          <SideCard
            label="Front"
            uri={front}
            onPick={() => void pick('front')}
            onClear={() => setFront(null)}
          />
          <SideCard
            label="Back (optional)"
            uri={back}
            onPick={() => void pick('back')}
            onClear={() => setBack(null)}
          />
        </div>
        {error && <p style={{ color: '#f87171' }}>{error}</p>}
        <IonButton
          expand="block"
          disabled={!front || busy}
          onClick={() => void onRecognize()}
        >
          {busy ? <IonSpinner name="crescent" /> : 'Recognize'}
        </IonButton>
      </IonContent>
    </IonPage>
  );
}

function SideCard({
  label,
  uri,
  onPick,
  onClear,
}: {
  label: string;
  uri: string | null;
  onPick: () => void;
  onClear: () => void;
}) {
  return (
    <div className="gallery-card">
      <div className="gallery-card-label">{label}</div>
      {uri ? (
        <img src={displayUri(uri) ?? uri} alt={label} className="gallery-thumb" />
      ) : (
        <div className="gallery-placeholder">No image</div>
      )}
      <IonButton size="small" expand="block" onClick={onPick}>
        Pick
      </IonButton>
      {uri && (
        <IonButton size="small" fill="clear" expand="block" onClick={onClear}>
          Clear
        </IonButton>
      )}
    </div>
  );
}
