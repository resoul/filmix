import base64
import json
import re
import time
from typing import Dict, Any, List, Optional
from urllib.parse import urlparse
import requests


class StreamProvider:
    def __init__(self, url: str):
        self.stream_id = self._get_id_from_url(url)
        uri = urlparse(url)

        path_parts = uri.path.strip('/').split('/')
        self.stream_category = path_parts[0] if path_parts else ''

        self.player_data_url = (
            f"{uri.scheme}://{uri.netloc}/api/movies/player-data"
            f"?t={int(time.time())}"
        )

        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })

    @staticmethod
    def _get_id_from_url(url: str) -> int:
        parts = url.split('/')
        if not parts:
            return 0

        last = parts[-1]
        sub_parts = last.split('-', 1)

        try:
            return int(sub_parts[0])
        except (ValueError, IndexError):
            return 0

    def _request(
            self,
            method: str,
            url: str,
            headers: Optional[Dict[str, str]] = None,
            data: Optional[Dict[str, Any]] = None
    ) -> requests.Response:
        kwargs = {'timeout': 10}

        if headers:
            kwargs['headers'] = headers

        if data:
            kwargs['data'] = data

        response = self.session.request(method, url, **kwargs)
        response.raise_for_status()

        return response

    def _send_request(self) -> Dict[str, Any]:
        headers = {
            'x-requested-with': 'XMLHttpRequest',
            'Cookie': 'FILMIXNET=ah3mgjr8vgfe84u86vcvu5gcp9'
        }

        data = {
            'post_id': str(self.stream_id),
            'showfull': 'true'
        }

        response = self._request('POST', self.player_data_url, headers=headers, data=data)
        return response.json()

    def get_stream_data(self) -> Dict[str, Any]:
        result = {}
        response = self._send_request()

        if response.get('type') != 'success':
            return result

        message = response.get('message', {})
        translations = message.get('translations', {})
        videos = translations.get('video', {})

        for translation, video in videos.items():
            if self.stream_category == 'film':
                decoded = self._decode(video)
                parts = decoded.split(',')
                result[translation] = self._convert_from_string(parts)
            else:
                try:
                    series_data = self._process_series_data(video)
                    result[translation] = series_data
                except Exception as e:
                    print(f"Warning: failed to process series data for {translation}: {e}")
                    continue

        return result

    def _process_series_data(self, video: str) -> Dict[str, Any]:
        decoded_url = self._decode(video)
        response = self._request('GET', decoded_url)
        series = response.json()

        result = {}

        for serie in series:
            title = serie.get('title', '').strip()
            folders = serie.get('folder', [])

            season_map = {}

            for folder in folders:
                folder_id = str(folder.get('id', ''))
                folder_title = folder.get('title', '').strip()
                file_str = folder.get('file', '')

                files = file_str.split(',')

                season_map[folder_id] = {
                    'title': folder_title,
                    'quality': self._convert_from_string(files)
                }

            result[title] = season_map

        return result

    def _convert_from_string(self, items: List[str]) -> Dict[str, str]:
        quality_list = {}
        pattern = re.compile(r'\[(.*?)\]')

        for item in items:
            match = pattern.search(item)
            if match:
                key = match.group(1)
                value = item.replace(match.group(0), '').strip()
                quality_list[key] = value

        return quality_list

    def is_movie(self) -> bool:
        return self.stream_category == 'film'

    def _decode(self, encoded_str: str) -> str:
        tokens = [
            ":<:bzl3UHQwaWk0MkdXZVM3TDdB",
            ":<:SURhQnQwOEM5V2Y3bFlyMGVI",
            ":<:bE5qSTlWNVUxZ01uc3h0NFFy",
            ":<:Mm93S0RVb0d6c3VMTkV5aE54",
            ":<:MTluMWlLQnI4OXVic2tTNXpU"
        ]

        if len(encoded_str) < 2:
            return encoded_str

        clean = encoded_str[2:]
        clean = clean.replace(r'\/', '/')

        while ':<:' in clean:
            for token in tokens:
                clean = clean.replace(token, '')

        try:
            decoded_bytes = base64.b64decode(clean)
            return decoded_bytes.decode('utf-8')
        except Exception:
            return ''


def main():
    film_url = "https://filmix.my/film/triller/173398-v-megan-k-vashim-uslugam-2024.html"

    try:
        provider = StreamProvider(film_url)
        data = provider.get_stream_data()

        print(f"\nType: {'Film' if provider.is_movie() else 'Serial'}")
        print(f"ID: {provider.stream_id}")
        print(json.dumps(data, indent=2, ensure_ascii=False))
    except Exception as e:
        print(f"Error: {e}")


if __name__ == '__main__':
    main()